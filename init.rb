# encoding: utf-8
require 'redmine'
require 'project'
require 'principal'
require 'user'

require File.join(File.dirname(__FILE__), 'app', 'models', 'git_repository_extra')
require File.join(File.dirname(__FILE__), 'app', 'models', 'git_cia_notification')

Redmine::Plugin.register :redmine_git_hosting do
	name 'Redmine Git Hosting Plugin'
	author 'Eric Bishop, Pedro Algarvio, Christian Käser, Zsolt Parragi, Yunsang Choi, Joshua Hogendorn, Jan Schulz-Hofen, John Kubiatowicz and others'
	description 'Enables Redmine / ChiliProject to control hosting of git repositories'
	version '0.4.5x'
	url 'https://github.com/ericpaulbishop/redmine_git_hosting'

	settings :default => {
		'httpServer' => 'redmine.beta-sandbox.com',
    		'httpServerSubdir' => '',
		'gitServer' => 'redmine.beta-sandbox.com',
		'gitUser' => 'git',
		'gitRepositoryBasePath' => 'repositories/',
    		'gitRedmineSubdir' => '',
    		'gitRepositoryHierarchy' => 'true',
    		'gitRecycleBasePath' => 'recycle_bin/',
    		'gitRecycleExpireTime' => '24.0',
    		'gitLockWaitTime' => '10',
		'gitoliteIdentityFile' => Rails.root + '/.ssh/gitolite_admin_id_rsa',
		'gitoliteIdentityPublicKeyFile' => Rails.root + '/.ssh/gitolite_admin_id_rsa.pub',
		'allProjectsUseGit' => 'false',
    		'gitDaemonDefault' => '1',   # Default is Daemon enabled
		'gitHttpDefault' => '1',     # Default is HTTP_ONLY
   		'gitNotifyCIADefault' => '0', # Default is CIA Notification disabled
		'deleteGitRepositories' => 'false',
		'gitRepositoriesShowUrl' => 'true',
		'gitCacheMaxTime' => '-1',
		'gitCacheMaxElements' => '100',
		'gitCacheMaxSize' => '16',
		'gitHooksDebug' => 'false',
		'gitHooksAreAsynchronous' => 'true',
    		'gitTempDataDir' => '/tmp/redmine_git_hosting/',
		'gitScriptDir' => ''
		},
		:partial => 'redmine_git_hosting'
		project_module :repository do
			permission :create_repository_mirrors, :repository_mirrors => :create
			permission :view_repository_mirrors, :repository_mirrors => :index
			permission :edit_repository_mirrors, :repository_mirrors => :edit
		end
end

Rails.configuration.to_prepare do

  require 'git_hosting'

  # initialize association from project -> repository mirrors
  Project.send(:has_many, :repository_mirrors, :dependent => :destroy)

  require 'projects_controller'
  require 'git_hosting/patches/projects_controller_patch'
  ProjectsController.send(:include, GitHosting::Patches::ProjectsControllerPatch)

  require 'repositories_controller'
  require 'git_hosting/patches/repositories_controller_patch'
  RepositoriesController.send(:include, GitHosting::Patches::RepositoriesControllerPatch)

  require 'repository'
  require 'git_hosting/patches/repository_patch'
  Repository.send(:include, GitHosting::Patches::RepositoryPatch)

  require 'stringio'
  require 'redmine/scm/adapters/git_adapter'
  require 'git_hosting/patches/git_adapter_patch'
  Redmine::Scm::Adapters::GitAdapter.send(:include, GitHosting::Patches::GitAdapterPatch)

  require 'groups_controller'
  require 'git_hosting/patches/groups_controller_patch'
  GroupsController.send(:include, GitHosting::Patches::GroupsControllerPatch)

  require 'repository'
  require 'repository/git'
  require 'git_hosting/patches/git_repository_patch'
  Repository::Git.send(:include, GitHosting::Patches::GitRepositoryPatch)

  require 'sys_controller'
  require 'git_hosting/patches/sys_controller_patch'
  SysController.send(:include, GitHosting::Patches::SysControllerPatch)

  require 'members_controller'
  require 'git_hosting/patches/members_controller_patch'
  MembersController.send(:include, GitHosting::Patches::MembersControllerPatch)

  # initialize association from user -> public keys
  User.send(:has_many, :gitolite_public_keys, :dependent => :destroy)

  require 'users_controller'
  require 'git_hosting/patches/users_controller_patch'
  UsersController.send(:include, GitHosting::Patches::UsersControllerPatch)
  
  require 'users_helper'
  require 'git_hosting/patches/users_helper_patch'
  UsersHelper.send(:include, GitHosting::Patches::UsersHelperPatch)
  
  require 'roles_controller'
  require 'git_hosting/patches/roles_controller_patch'
  RolesController.send(:include, GitHosting::Patches::RolesControllerPatch)

  require 'my_controller'
  require 'git_hosting/patches/my_controller_patch'
  MyController.send(:include, GitHosting::Patches::MyControllerPatch)

  require 'git_hosting/patches/repository_cia_filters'
  
end

# initialize hooks
class GitProjectShowHook < Redmine::Hook::ViewListener
	render_on :view_projects_show_left, :partial => 'git_urls'
end

class GitRepoUrlHook < Redmine::Hook::ViewListener
	render_on :view_repositories_show_contextual, :partial => 'git_urls'
end


# initialize observer
RedmineApp::Application.configure do
  config.after_initialize do
  	if config.action_controller.perform_caching
  		ActiveRecord::Base.observers = ActiveRecord::Base.observers << GitHostingObserver
  		ActiveRecord::Base.observers = ActiveRecord::Base.observers << GitHostingSettingsObserver

  		config.to_prepare do
  			GitHostingObserver.instance.reload_this_observer
  		end
  		config.to_prepare do
  			GitHostingSettingsObserver.instance.reload_this_observer
  		end
  	end
  end
end

