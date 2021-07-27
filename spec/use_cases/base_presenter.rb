# Base Presenter
#
# Use BasePresenter to provide a simple data model to the view.
#
# Any view logic can easily be represented here
class BasePresenter
  include Interactor
  include Interactor::Guard

  class << self
    def present(context = {})
      factory = new(context).tap(&:run)
      factory.context
    end

    def present!(context = {})
      factory = new(context).tap(&:run!)
      factory.context
    end

    def present_collection(context = {})
      # TODO - present collections
      # TODO - present paginated collections
    end
  end

  def call
    present
  end

  # Implement this method in your factory and return the class present
  def present; end
end

