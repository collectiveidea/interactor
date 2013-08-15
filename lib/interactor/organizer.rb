module Interactor
  module Organizer
    def self.included(base)
      base.send(:include, Interactor)
    end
  end
end
