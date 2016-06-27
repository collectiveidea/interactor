module Interactor
  # Public: Interactor::Switcher methods. Because Interactor::Switcher is a
  # module, custom Interactor::Switcher classes should include
  # Interactor::Switcher rather than inherit from it.
  #
  # Examples
  #
  #   class MySwitcher
  #     include Interactor::Switcher
  #
  #     switch case_1: InteractorOne, case_2: InteractorTwo
  #   end
  module Switcher
    # Internal: Install Interactor::Switcher's behavior in the given class.
    def self.included(base)
      base.class_eval do
        include Interactor

        extend ClassMethods
        include InstanceMethods
      end
    end

    # Internal: Interactor::Switcher class methods.
    module ClassMethods
      # Public: Declare Interactors to be invoked as part of the
      # Interactor::Switcher's invocation. These interactors are invoked based
      # on the specfied switcher_condition attribute of context.
      # 
      # If switcher_condition attribute is not specified, the first argument
      # of the specified cases will be executed
      #
      # interactors
      # - Zero or more (or an Array of) Interactor classes.
      # - Only one Array (flat or nested) of Interactor classes
      # - Only one Hash where:
      #   - Key defines the case
      #   - Value single or an Array of Interactor classes.
      #
      # Examples:
      #
      #   class MyFirstSwitcher
      #     include Interactor::Switcher
      #     
      #     # Providing two cases as Interactor arguments
      #     switch InteractorOne, InteractorTwo
      #   end
      #
      #   class MyFirstSwitcher
      #     include Interactor::Switcher
      #
      #     # Providing one case as an Array of Interactor arguments
      #     switch [InteractorOne, InteractorTwo]
      #   end
      #
      #   class MySecondSwitcher
      #     include Interactor::Switcher
      #
      #     # Providing three cases as Arrays of Interactor arguments
      #     switch [InteractorThree, InteractorFour],
      #         [InteractorOne, InteractorTwo],
      #         [InteractorOne]
      #   end
      #
      #   class MySecondSwitcher
      #     include Interactor::Switcher
      #
      #     # Providing three cases as a Hash of Interactor arguments
      #     switch { 
      #        path_1: [InteractorThree, InteractorFour],
      #        path_2: InteractorOne,
      #        path_3: [InteractorOne]
      #     }
      #   end
      #
      # Returns nothing.
      def switch(*interactors)
        @cases = interactors.first.is_a?(Hash) ? interactors.first : interactors
      end

      # Internal: An Array or Hash of declared paths to be invoked.
      #
      # Examples
      #
      #   class MySwitcher
      #     include Interactor::Switcher
      #
      #     switch [InteractorOne, InteractorTwo]
      #   end
      #
      #   MySwitcher.cases
      #   switch { 
      #         path_1: [InteractorThree, InteractorFour],
      #         path_2: [InteractorOne, InteractorTwo],
      #         path_3: InteractorOne
      #    }
      #
      # Returns an Array or Hash of Interactor classes or an empty Array.
      def cases
        @cases ||= []
      end

    end

    # Internal: Interactor::Switcher instance methods.
    module InstanceMethods
      # Internal: Invoke the organized Interactors. An Interactor::Switcher is
      # expected not to define its own "#call" method in favor of this default
      # implementation.
      #
      # Returns nothing.
      def call
        cases = self.class.cases

        unless cases.empty?
          body = cases[context.switcher_condition]\
            unless context.switcher_condition.nil?
          body ||= cases.is_a?(Hash) ? cases.values.first : cases.first

          if body.is_a? Array
            body.each { |interactor| interactor.call! context }
          else
            body.call! context
          end
        end
      end

    end
  end
end