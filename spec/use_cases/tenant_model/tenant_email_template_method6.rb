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
  #  - simplify case statement using meta programming
  #  - TENANT is FAT
  #    proper name spacing
  class Tenant_6
    def contextual_email_template(klass)
      template_id = template_id_for_context(klass) 

      contextual_email_template_valid_template?(template_id) ? template_id : contextual_email_template_default_template_id
    end

    def contextual_email_template_valid_template?(template_id)
      EmailTemplate.by_tenant(self).exist?(id: template_id)
    end

    def contextual_email_template_default_template_id
      self.enterprise.default_email_template_id || 0
    end

    def template_id_for_context(klass)
      context_name = klass.name.underscore
      self.send("#{context_name}_email_template") || self.enterprise.send("default_#{context_name}_emailt_id")
    end
 end
end
