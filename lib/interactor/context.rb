require "delegate"

module Interactor
  class Context < SimpleDelegator
    def self.build(context = {})
      self === context ? context : new(context.dup)
    end

    def initialize(context = {})
      super(context)
    end

    def success?
      !failure?
    end

    def failure?
      @failure || false
    end

    def halted?
      @halt || false
    end

    def fail!(context = {})
      update(context)
      @failure = true
    end

    def halt!(context = {})
      update(context)
      @halt = true
    end
  end
end
