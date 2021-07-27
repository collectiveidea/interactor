# frozen_string_literal: true

module Factories
  # Changes:
  #  - Result to template_id so that it is obvious what is returned
  #  - extract valid_template? which is more efficient as a query
  #  - simplify valid_template | default_template selection
  #  - case of zero:
  #    - zero does not exist in the Australian database (not sure about US/EU).
  #    - zero is a valid ID in a Postgres database, just not this table
  #  - simplify case statement using meta programming
  class Tenant_7
    def contextual_email_template_id(klass)
      context_name = klass.name.underscore

      template_id = self.send("#{context_name}_email_template") ||
                    self.enterprise.send("default_#{context_name}_emailt_id")

      return template_id if EmailTemplate.by_tenant(self).exist?(id: template_id)

      self.enterprise.default_email_template_id || 0
    end
  end
end
