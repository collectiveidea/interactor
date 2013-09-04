require "delegate"

module Interactor
  class Context < SimpleDelegator
    def self.build(context = {})
      self === context ? context : new(context)
    end

    def success?
      !failure?
    end

    def failure?
      @failure || false
    end

    def fail!(context = {})
      update(context)
      @failure = true
    end
  end
end
