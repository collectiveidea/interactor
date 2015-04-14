module Interactor
  module Contract
    describe PropertyTable do
      let(:table) { Interactor::Contract::PropertyTable.new }

      describe "#set" do
        it "initializes a new property" do
          table.set(:property1, presence: :expected, default: :method_name)

          property = table.get(:property1)
          expect(property).to be_a(Interactor::Contract::Property)
          expect(property.default).to eq(:method_name)
          expect(property.presence).to eq(:expected)
        end
      end

      describe "#select" do
        it "selects the properties with matching options" do
          table.set(:property1, presence: :expected, default: :method_name)
          table.set(:property2, presence: :expected)
          table.set(:property3, presence: :permitted, default: :method_name)

          properties = table.select(presence: :expected)
          expect(properties.keys).to include(:property1)
          expect(properties.keys).to include(:property2)
          expect(properties.keys).not_to include(:property3)

          properties = table.select(presence: :expected, default: :method_name)
          expect(properties.keys).to include(:property1)
          expect(properties.keys).not_to include(:property2)
          expect(properties.keys).not_to include(:property3)
        end
      end

      describe "#expected_properties" do
        it "returns only the properties where their presence is expected" do
          table.set(:property1, presence: :expected)
          table.set(:property2, presence: :permitted)

          expect(table.expected_properties).to include(:property1)
          expect(table.expected_properties).not_to include(:property2)
        end
      end

      describe "#default_for" do
        it "return the default for a property with a default set" do
          table.set(:property, default: :method_name)

          expect(table.default_for(:property)).to eq(:method_name)
        end
      end
    end
  end
end