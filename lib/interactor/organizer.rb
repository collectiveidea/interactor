module Interactor
  # Public: Interactor::Organizer methods. Because Interactor::Organizer is a
  # module, custom Interactor::Organizer classes should include
  # Interactor::Organizer rather than inherit from it.
  #
  # Examples
  #
  #   class MyOrganizer
  #     include Interactor::Organizer
  #
  #     organize InteractorOne, InteractorTwo
  #   end
  module Organizer
    # Internal: Install Interactor::Organizer's behavior in the given class.
    def self.included(base)
      base.class_eval do
        include Interactor

        extend ClassMethods
        include InstanceMethods
      end
    end

    # Internal: Interactor::Organizer class methods.
    module ClassMethods
      # Public: Declare Interactors to be invoked as part of the
      # Interactor::Organizer's invocation. These interactors are invoked in
      # the order in which they are declared.
      #
      # interactors - Zero or more (or an Array of) Interactor classes.
      #
      # Examples
      #
      #   class MyFirstOrganizer
      #     include Interactor::Organizer
      #
      #     organize InteractorOne, InteractorTwo
      #   end
      #
      #   class MySecondOrganizer
      #     include Interactor::Organizer
      #
      #     organize [InteractorThree, InteractorFour]
      #   end
      #
      # Returns nothing.
      def organize(*interactors)
        @organized = interactors.flatten
      end

      # Internal: An Array of declared Interactors to be invoked.
      #
      # Examples
      #
      #   class MyOrganizer
      #     include Interactor::Organizer
      #
      #     organize InteractorOne, InteractorTwo
      #   end
      #
      #   MyOrganizer.organized
      #   # => [InteractorOne, InteractorTwo]
      #
      #   class MyConditionalOrganizer
      #     include Interactor::Organizer
      #
      #     def true_method() { true }
      #     def false_method() { false }
      #
      #     organize { class: InteractorOne, if: :true_method }, { class: InteractorTwo, if: :false_method }
      #   end
      #
      #   MyConditionalOrganizer.organized
      #   # => { class: InteractorOne, if: :true_method }, { class: InteractorTwo, if: :false_method }
      #
      # Returns an Array of Interactor classes or an empty Array.
      def organized
        @organized ||= []
      end
    end

    # Internal: Interactor::Organizer instance methods.
    module InstanceMethods
      # Internal: Invoke the organized Interactors. An Interactor::Organizer is
      # expected not to define its own "#call" method in favor of this default
      # implementation.
      #
      # Returns nothing.
      def call
        self.class.organized.each do |interactor|
          if interactor.is_a?(Hash)
            interactor[:class].call!(context) if interactor[:if].nil? || send(interactor[:if])
          else
            interactor.call!(context)
          end
        end
      end
    end
  end
end
