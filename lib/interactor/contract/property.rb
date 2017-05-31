module Interactor
  module Contract
    class Property
      DEFAULTS = { presence: :provided }

      VALID_OPTIONS = {
        presence: [:expected, :permitted, :provided]
      }

      attr_accessor :default, :on_violation, :presence

      def initialize(opts={})
        validate_options(opts)
        opts = DEFAULTS.merge(opts)
        @default      = opts[:default]
        @on_violation = opts[:on_violation]
        @presence     = opts[:presence]
      end

      def merge!(hash)
        hash.each do |k, v|
          send("#{k}=", v)
        end
      end

      private

      def validate_options(opts)
        opts.each do |k, v|
          next unless values = VALID_OPTIONS[k]
          raise "Invalid value '#{v}' for option #{k}" unless values.include?(v)
        end
      end
    end
  end
end