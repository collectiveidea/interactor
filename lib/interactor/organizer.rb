module Interactor
  module Organizer
    def self.included(base)
      base.class_eval do
        include Interactor

        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      def organize(*interactors)
        @organized = interactors.flatten
      end

      def organized
        @organized ||= []
      end
    end

    module InstanceMethods
      def call
        self.class.organized.each do |interactor|
          interactor.call!(context)
        end
      end
    end
  end
end
