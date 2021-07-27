# frozen_string_literal: true

module Factories
  # Changes:
  #  - Result to template_id so that it is obvious what is returned
  #  - extract valid_template? which is more efficient as a query
  #  - simplify valid_template | default_template selection
  #  - case of zero:
  #    - zero does not exist in the Australian database (not sure about US/EU).
  #    - zero is a valid ID in a Postgres database, just not this table
  #  - or (short circuit) operator
  class Tenant_4
    def contextual_email_template(klass)
      template_id = if klass == Estimate
                      self.estimate_email_template || self.enterprise.default_estimate_emailt_id
                    elsif klass == Order
                      self.order_email_template || self.enterprise.default_order_emailt_id
                    elsif klass == Sale
                      self.sale_email_template || self.enterprise.default_sale_emailt_id 
                    elsif klass == Contact
                      self.contact_email_template || self.enterprise.default_contact_emailt_id
                    elsif klass == Company
                      self.company_email_template || self.enterprise.default_company_emailt_id
                    elsif klass == Inquiry
                      self.inquiry_email_template || self.enterprise.default_inquiry_emailt_id
                    end
  
      valid_template?(template_id) ? template_id : default_template_id
    end

    def valid_template?(template_id)
      EmailTemplate.by_tenant(self).exist?(id: template_id)
    end

    def default_template_id
      self.enterprise.default_email_template_id || 0
    end
  end
end
