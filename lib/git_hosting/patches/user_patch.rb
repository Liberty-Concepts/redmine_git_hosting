
module GitHosting
	module Patches
		module UserPatch

      def self.included(base) # :nodoc:
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          has_many :gitolite_public_keys, :dependent => :destroy
      
        end

      end
  
      module ClassMethods
    
      end
  
      module InstanceMethods
        
      end   
		end
	end
end
