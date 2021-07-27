# Add numbers
#
# Demonstrates paramater guards
# Demonstrates context delegates
module TooSimple
  class AddNumbers
    include Interactor
    include Interactor::Guard

    delegate :lhs, :rhs, to: :context

    def call
      guard(:lhs, :rhs)

      context.sum = context.lhs + context.rhs
    end
  end
end