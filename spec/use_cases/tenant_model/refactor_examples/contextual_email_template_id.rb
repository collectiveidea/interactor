# frozen_string_literal: true

module Helpers
  def usage
    @estimate_template_id = ContextualEmailTemplateId.call(tenant: @tenant, type: Estimate)
    @order_template_id    = ContextualEmailTemplateId.call(tenant: @tenant, type: Order)
    @contact_template_id  = ContextualEmailTemplateId.call(tenant: @tenant, type: Contact)
  end

  class ContextualEmailTemplateId < BaseHelper
    VALID_TYPES = [] # Estimate, Order, Sale, Contact, Company, Inquiry]

    delegate :tenant, :type, to: :context

    def instance
      guard(:tenant, :type)
      guard("Invalid Type: #{type}") unless VALID_TYPES.include?(type)

      valid_template? ? template_id : default_template_id
    end

    private

    def valid_template?
      EmailTemplate.by_tenant(self).exist?(id: template_id)
    end

    def default_template_id
      self.enterprise.default_email_template_id || 0
    end

    def template_id
      return @template_id if defined? @template_id

      context_name = type.name.underscore
      @template_id = self.send("#{context_name}_email_template") || self.enterprise.send("default_#{context_name}_emailt_id")
    end
  end
end
