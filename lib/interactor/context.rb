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

    def succeed!(context = {})
      @failure = false
      update(context)
    end

    def fail!(context = {})
      @failure = true
      update(context)
    end
  end
end
