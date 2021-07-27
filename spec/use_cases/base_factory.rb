# Base Factory
#
# Use BaseFactory as a container for a factory method.
# 
# Examples include
#  - EmailTemplateFactory
#  - TenantEmailTemplateFactory
#  - UserEmailTemplateFactory
class BaseFactory
  include Interactor
  include Interactor::Guard

  class << self
    def instance(context = {})
      factory = new(context).tap(&:run)
      factory.context.instance
    end

    def instance!(context = {})
      factory = new(context).tap(&:run!)
      factory.context.instance
    end

    def instance_as_context(context = {})
      factory = new(context).tap(&:run)
      factory.context
    end
  end

  def call
    context.instance = instance
  end

  # Implement this method in your factory and return the class instance
  def instance; end
end

