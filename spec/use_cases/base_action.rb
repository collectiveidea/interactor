# Base Action
#
# Use BaseAction for simple actions that do one action.
# 
# Action based Service Object with Single Responsibly
#
# Examples include
#  - SignInUser
#  - AuthenticateUser
#  - PlaceOrder
#  - EmailWelcomeLetter
#  - DeleteAccount
class BaseAction
  include Interactor
  include Interactor::Guard
end
