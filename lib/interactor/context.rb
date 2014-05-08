require "ostruct"

module Interactor
  class Context < OpenStruct
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
      modifiable.update(context)
      @failure = true
      raise Failure
    end
  end
end
