module Interactor
  module Contract
    VALID_TYPES = %i(open closed)

    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end

      def violation_table
        @violation_table ||= {}
      end

      def validate_contract_expectations
        missing_properties.each do |property_name|
          violation_table[property_name] = ContractViolation.new(
            self,
            property: property_name,
            message: "Expected context to include property '#{property_name}'."
          )
        end

        extra_properties.each do |property_name|
          violation_table[property_name] = ContractViolation.new(
            self,
            property: property_name,
            message: "Expected context not to include property '#{property_name}'."
          )
        end
      end

      def missing_properties
        @missing_properties ||= self.class.property_table.missing_properties(context)
      end

      def extra_properties
        @extra_properties ||= begin
          if self.class.contract_open?
            []
          else
            self.class.property_table.undeclared_properties(context)
          end
        end
      end

      def ensure_contract_defaults
        self.class.all_properties.each do |attr|
          send(attr) if context[attr].nil? && self.class.default_for(attr)
        end
      end

      def check_each_violation
        return if violation_table.empty?
        violation_table.each do |property_name, violation|
          if block = self.class.property_table.get(property_name).on_violation
            block.call(context)
          elsif self.class.on_violation_block
            self.class.on_violation_block.call(violation, context)
          else
            raise violation
          end
        end
      end
    end

    module ClassMethods
      # Core DSL
      #
      def contract_type(value)
        raise "Invalid contract type '#{value}'" unless Interactor::Contract::VALID_TYPES.include?(value)
        @contract_type = value
      end

      def property(attr, opts={}, &block)
        opts.merge!(default: block) if block
        property_table.set(attr, opts)

        delegate_properties
      end

      def on_violation_for(*args, &block)
        args.each do |arg|
          if property = property_table.get(arg)
            property.on_violation = block
          else
            property_table.set(arg, on_violation: block)
          end
        end
      end

      def on_violation(&block)
        @on_violation_block = block
      end

      # Sugar for core DSL
      def expects(*args, &block)
        opts = args.detect { |arg| arg.is_a?(Hash) } || {}
        opts.merge!(presence: :expected)
        args.reject! { |arg| arg.is_a?(Hash) }

        args.each do |arg|
          property(arg, opts, &block)
        end
      end

      def permits(*args, &block)
        opts = args.detect { |arg| arg.is_a?(Hash) } || {}
        opts.merge!(presence: :permitted)
        args.reject! { |arg| arg.is_a?(Hash) }

        args.each do |arg|
          property(arg, opts, &block)
        end
      end

      def provides(*args, &block)
        opts = args.detect { |arg| arg.is_a?(Hash) } || {}
        opts.merge!(presence: :provided)
        args.reject! { |arg| arg.is_a?(Hash) }

        args.each do |arg|
          property(arg, opts, &block)
        end
      end

      def on_violation_block
        @on_violation_block
      end

      def delegate_properties
        all_properties.each do |attr|
          define_method attr do
            next context[attr] if context[attr]
            if default = self.class.default_for(attr)
              if default.is_a?(Proc)
                context[attr] = default.call
              else
                context[attr] = self.send(default)
              end
            end
          end

          define_method "#{attr}=" do |value|
            context[attr] = value
          end
        end
      end

      def contract_open?
        [nil, :open].include?(@contract_type)
      end

      def contract_closed?
        !contract_open?
      end

      def property_table
        @property_table ||= PropertyTable.new
      end

      def expected_properties;  property_table.expected_properties; end
      def permitted_properties; property_table.permitted_properties; end
      def provided_properties;  property_table.provided_properties; end
      def all_properties;       property_table.all_properties; end
      def default_for(attr);    property_table.default_for(attr); end

      def expected_and_permitted_properties
        property_table.expected_and_permitted_properties
      end
    end
  end
end