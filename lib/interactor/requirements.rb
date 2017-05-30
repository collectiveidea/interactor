module Interactor

  module Requirements

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def context_requires(*params)
        if params.empty?
          raise "Must specify at least one param"
        end
        typed_params = nil
        if params.last.is_a? Hash
          typed_params = params.pop
        end

        # We need to check the typed_params for existence as well
        params = params + typed_params.keys unless typed_params.nil?

        before do
          params.each do |param_name|
            if !context.respond_to?(param_name)
              raise RequirementsNotMet, "Context requires #{param_name}, but it wasn't specified"
            elsif context.send(param_name).nil?
              raise RequirementsNotMet, "Context requires #{param_name}, but it was nil"
            end
          end
          next if typed_params.nil?
          typed_params.each do |param_name, param_type|
            raise RequirementsNotMet, "The type specified for #{param_name} must be a Class (got #{param_type.class})" if param_type.class != Class
            given_value = context.send(param_name)
            if !given_value.is_a? param_type
              raise RequirementsNotMet, "Context requires #{param_name} to be a #{param_type}, but it was a #{given_value.class}."
            end
          end
        end
      end
    end

  end
end
