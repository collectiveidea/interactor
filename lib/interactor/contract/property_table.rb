module Interactor
  module Contract
    class PropertyTable
      def initialize
        @table ||= {}
      end

      def get(property_name)
        @table[property_name]
      end

      def set(property_name, opts={})
        @table[property_name] ||= Property.new(opts)
        @table[property_name].merge!(opts)
      end

      def each_property
        @table.each do |property_name, property|
          yield property_name, property
        end
      end

      def select(args)
        @table.select do |_, property|
          args == args.select do |k, v|
            property.send(k) == v
          end
        end
      end

      def expected;  select(presence: :expected); end
      def permitted; select(presence: :permitted); end
      def provided;  select(presence: :provided); end

      def all_properties; @table.keys; end
      def expected_properties; expected.keys; end
      def permitted_properties; permitted.keys; end
      def provided_properties; provided.keys; end

      def expected_and_permitted_properties
        expected_properties + permitted_properties
      end

      def default_for(property_name)
        @table[property_name].default
      end
    end
  end
end