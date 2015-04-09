module Interactor
  module Contract
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end

      def validate_contract_expectations
        missing_properties = self.class.required_properties.select do |attr|
          !context.members.include?(attr)
        end

        if missing_properties.any?
          raise ContractError.new(
                  self,
                  missing:    missing_properties,
                )
        end
      end

      def ensure_contract_defaults
        self.class.all_properties.each do |attr|
          self.send(attr) if context[attr].nil? && self.class.attribute_defaults[attr]
        end
      end
    end

    module ClassMethods

      def property(attr, opts={}, &block)
        case opts.fetch(:presence, :provided)
          when :required  then required_properties << attr
          when :permitted then permitted_properties << attr
          when :provided  then provided_properties << attr
          else
            raise ContractError, message: "Invalid value '#{opts[:presence]}' for option 'presence'."
        end

        if block
          attribute_defaults.merge!(attr => block)
        else
          attribute_defaults.merge!(attr => opts[:default])
        end

        delegate_properties
      end

      def expects(*args, &block)
        opts = args.detect { |arg| arg.is_a?(Hash) } || {}
        opts.merge!(presence: :required)
        args.reject! { |arg| arg.is_a?(Hash) }

        args.each do |arg|
          property(arg, opts, &block)
        end
      end

      def allows(*args, &block)
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

      def delegate_properties
        all_properties.each do |attr|
          define_method attr do
            next context[attr] if context[attr]
            if default = self.class.attribute_defaults[attr]
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

      def required_properties
        @required_properties ||= []
      end

      def permitted_properties
        @permitted_properties ||= []
      end

      def provided_properties
        @provided_properties ||= []
      end

      def attribute_defaults
        @attribute_defaults ||= {}
      end

      def required_and_permitted_properties
        required_properties + permitted_properties
      end

      def all_properties
        required_properties +
          permitted_properties +
          provided_properties
      end

    end
  end
end