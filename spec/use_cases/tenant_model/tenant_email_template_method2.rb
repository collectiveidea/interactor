# frozen_string_literal: true

module Factories
  # Changes:
  #  - Rename result to template_id so that it is obvious what is returned
  #  - extract valid_template? which is more efficient as a query
  class Tenant_2
    def contextual_email_template(klass)
      template_id = 0
  
      if klass == Estimate
        template_id = self.estimate_email_template
        template_id = self.enterprise.default_estimate_emailt_id if template_id.nil? || template_id == 0
      elsif klass == Order
        template_id = self.order_email_template
        template_id = self.enterprise.default_order_emailt_id if template_id.nil? || template_id == 0
      elsif klass == Sale
        template_id = self.sale_email_template
        template_id = self.enterprise.default_sale_emailt_id if template_id.nil? || template_id == 0 
      elsif klass == Contact
        template_id = self.contact_email_template
        template_id = self.enterprise.default_contact_emailt_id if (template_id.nil? || template_id == 0)
      elsif klass == Company
        template_id = self.company_email_template
        template_id = self.enterprise.default_company_emailt_id if template_id.nil? || template_id == 0
      elsif klass == Inquiry
        template_id = self.inquiry_email_template
        template_id = self.enterprise.default_inquiry_emailt_id if template_id.nil? || template_id == 0
      end
  
      template_id = 0 unless valid_template?(template_id)
  
      template_id = self.enterprise.default_email_template_id if template_id.nil? || template_id == 0
  
      template_id
    end

    def valid_template?(template_id)
      # by_tenant is complex and so this makes sense as it's own unit of work
      EmailTemplate.by_tenant(self).exist?(id: template_id)
    end
  end
end
