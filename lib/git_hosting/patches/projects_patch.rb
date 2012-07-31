
module GitHosting
	module Patches
		module ProjectsPatch

      def self.included(base) # :nodoc:
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          has_many :repository_mirrors, :dependent => :destroy
      
        end

      end
  
      module ClassMethods
    
      end
  
      module InstanceMethods
        
      end   
		end
	end
end
