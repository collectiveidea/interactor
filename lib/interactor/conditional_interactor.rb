module Interactor
  # Internal: this class allows us to run interactors with regard of given
  # options, such as :if, :unless, :before, :after
  class ConditionalInteractor
    attr_reader :interactor, :options

    def initialize(interactor, options = {})
      @interactor = interactor
      @options = options
    end

    def call!(context, within_organizer)
      interactor.call!(context) if permitted_to_call?(within_organizer)
    end

    private

    def permitted_to_call?(organizer)
      permitted_by_if?(organizer) && permitted_by_unless?(organizer)
    end

    def permitted_by_if?(organizer)
      return true unless options[:if]
      execute_within_organizer(organizer, options[:if])
    end

    def permitted_by_unless?(organizer)
      return true unless options[:unless]
      !execute_within_organizer(organizer, options[:unless])
    end

    def execute_within_organizer(organizer, symbol_or_proc)
      if symbol_or_proc.is_a?(Symbol)
        symbol_or_proc.to_proc.call(organizer)
      else
        organizer.instance_exec(&symbol_or_proc)
      end
    end
  end
end
