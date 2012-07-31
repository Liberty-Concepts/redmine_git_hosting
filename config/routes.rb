RedmineApp::Application.routes.draw do
	# URL for items of type httpServer/XXX.git.  Some versions of rails has problems with multiple regex expressions, so avoid...
  	# Note that 'http_server_subdir' is either empty (default case) or ends in '/'.
	match ":project_path/*path" => 'git_http#show', 
  		:prefix => Setting.plugin_redmine_git_hosting['httpServerSubdir'], :project_path => /([^\/]+\/)*?[^\/]+\.git/

	# Handle the public keys plugin to my/account.
  scope 'my' do
  	resources :public_keys, :controller => :gitolite_public_keys
  end
	match 'my/account/public_key/:public_key_id' => 'my#account', :via => [:get]
	match 'users/:id/edit/public_key/:public_key_id' => 'users#edit', :via => [:get]

  	# Handle hooks and mirrors
	match 'githooks' => 'gitolite_hooks#stub'
	match 'githooks/post-receive' => 'gitolite_hooks#post_receive'
	match 'githooks/test' => 'gitolite_hooks#test'
	match 'projects/:project_id/settings/repository/mirrors/new' => 'repository_mirrors#create', :via => [:get, :post]
	match 'projects/:project_id/settings/repository/mirrors/edit/:id' => 'repository_mirrors#edit'
	match 'projects/:project_id/settings/repository/mirrors/push/:id' => 'repository_mirrors#push'
	match 'projects/:project_id/settings/repository/mirrors/update/:id' => 'repository_mirrors#update', :via => :post
	match 'projects/:project_id/settings/repository/mirrors/delete/:id' => 'repository_mirrors#destroy', :via => [:get, :delete]

end

