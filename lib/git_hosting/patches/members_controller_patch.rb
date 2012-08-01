

module GitHosting
	module Patches
		module MembersControllerPatch         
      
      def self.included(base)
      	base.send(:include, InstanceMethods)
      	base.class_eval do
      		alias_method_chain :new, :disable_update
          alias_method_chain :edit, :disable_update
          alias_method_chain :destroy, :disable_update
        end
      end

      module InstanceMethods
        def new_with_disable_update
          Rails.logger.info("new_with_disable_update")
          # Turn of updates during repository update
       		GitHostingObserver.set_update_active(false);

       		# Do actual update
       		new_without_disable_update

       		# Reenable updates to perform a single update
          GitHostingObserver.set_update_active(true);
       	end
        def edit_with_disable_update
          Rails.logger.info("edit_with_disable_update")
             	# Turn of updates during repository update
       		GitHostingObserver.set_update_active(false);

       		# Do actual update
       		edit_without_disable_update

       		# Reenable updates to perform a single update
          GitHostingObserver.set_update_active(true);
       	end
        def destroy_with_disable_update
          Rails.logger.info("destroy_with_disable_update")
             	# Turn of updates during repository update
       		GitHostingObserver.set_update_active(false);

       		# Do actual update
       		destroy_without_disable_update

       		# Reenable updates to perform a single update
          GitHostingObserver.set_update_active(:delete => true);
       	end
      	
      end
      
		end
	end
end
