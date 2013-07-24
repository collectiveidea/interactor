module Interactor
  class Context < ::Hash
    def self.build(context = {})
      self === context ? context : new.replace(context)
    end
  end
end
