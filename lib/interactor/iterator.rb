module Interactor
  module Iterator
    def self.included(base)
      base.class_eval do
        include Interactor

        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
    end

    module InstanceMethods
    end
  end
end
