module Interactor
  class Failure
    def initialize(instance)
      @instance = instance
    end

    def perform
      yield if @instance.failure?
    end
  end
end
