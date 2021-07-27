# Base Decorator
#
# Use BaseDecorator for decorating a PORO with extra view
# or read-only methods. Usually these methods a complex
class BaseDecorator
  include Interactor
  include Interactor::Guard
end
