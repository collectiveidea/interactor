# Base Helper
#
# Use BaseHelper directly from module helper methods in the
# case where those methods are to complex and a SRP class with
# state and additional methods would reduce complexity
class BaseHelper
  include Interactor
  include Interactor::Guard
end
