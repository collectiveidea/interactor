module Interactor
  class Context < ::Hash
    def self.build(context = {})
      self === context ? context : new.replace(context)
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
