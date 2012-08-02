

module GitHosting
	module Patches
		module MembersControllerPatch         
      
      def self.included(base)
      	base.send(:include, InstanceMethods)
      	base.class_eval do
      		alias_method_chain :create, :disable_update
          alias_method_chain :update, :disable_update
          alias_method_chain :destroy, :disable_update
        end
      end

      module InstanceMethods
        def create_with_disable_update
          # Rails.logger.info("new_with_disable_update")
          # Turn of updates during repository update
       		GitHostingObserver.set_update_active(false)

       		# Do actual update
       		create_without_disable_update

       		# Reenable updates to perform a single update
          GitHostingObserver.set_update_active(:resync_all)
       	end
        def update_with_disable_update
          # Rails.logger.info("edit_with_disable_update")
             	# Turn of updates during repository update
       		GitHostingObserver.set_update_active(false)

       		# Do actual update
       		update_without_disable_update

       		# Reenable updates to perform a single update
          GitHostingObserver.set_update_active(:resync_all)
       	end
        def destroy_with_disable_update
          # Rails.logger.info("destroy_with_disable_update")
             	# Turn of updates during repository update
       		GitHostingObserver.set_update_active(false)

       		# Do actual update
       		destroy_without_disable_update

       		# Reenable updates to perform a single update
          GitHostingObserver.set_update_active(:resync_all) #:delete => true);
       	end
      	
      end
      
		end
	end
end
