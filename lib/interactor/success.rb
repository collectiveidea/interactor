module Interactor
  class Success
    def initialize(instance)
      @instance = instance
    end

    def perform
      yield if @instance.success?
    end
  end
end
