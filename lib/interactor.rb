module Interactor
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    def perform(context = {})
      new(context).tap(&:perform)
    end
  end
end
