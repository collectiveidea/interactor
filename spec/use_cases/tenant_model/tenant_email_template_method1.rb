# frozen_string_literal: true

module Factories
  # Current method on the tenant class
  class Tenant_1
    def contextual_email_template(klass)
      template_ids = EmailTemplate.by_tenant(self).pluck(:id)
      result = 0
  
      if klass == Estimate
        result = self.estimate_email_template
        result = self.enterprise.default_estimate_emailt_id if result.nil? || result == 0
      elsif klass == Order
        result = self.order_email_template
        result = self.enterprise.default_order_emailt_id if result.nil? || result == 0
      elsif klass == Sale
        result = self.sale_email_template
        result = self.enterprise.default_sale_emailt_id if result.nil? || result == 0 
      elsif klass == Contact
        result = self.contact_email_template
        result = self.enterprise.default_contact_emailt_id if (result.nil? || result == 0)
      elsif klass == Company
        result = self.company_email_template
        result = self.enterprise.default_company_emailt_id if result.nil? || result == 0
      elsif klass == Inquiry
        result = self.inquiry_email_template
        result = self.enterprise.default_inquiry_emailt_id if result.nil? || result == 0
      end
  
      result = 0 unless template_ids.include?(result)
  
      result = self.enterprise.default_email_template_id if result.nil? || result == 0
  
      result
    end
  end
end
