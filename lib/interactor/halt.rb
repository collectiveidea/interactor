module Interactor
  # Internal: Error raised when Interactor::Context gets halted.
  # Behaves exactly like Failure error
  class Halt < Failure
  end
end
