include RSpec::Mocks::ExampleMethods

module Interactor
  # Public: Interactor::TestHelpers methods.
  #
  # Examples:
  #
  #   RSpec.describe ExampleOrganizer do
  #     include Interactor::TestHelpers
  #     ...
  #   end
  module TestHelpers
    # Public: Stub all Interactors organized by an Organizer.
    #
    # Examples:
    #
    #   before(:example) do
    #     mock_organizer(ExampleOrganizer)
    #   end
    #
    #   describe ".call" do
    #     it "calls FirstInteractor" do
    #       expect(FirstInteractor).to receive(:call!)
    #       ExampleOrganizer.call
    #     end
    #
    #     it "calls SecondInteractor" do
    #       expect(SecondInteractor).to receive(:call!)
    #       ExampleOrganizer.call
    #     end
    #   end
    def mock_organizer(organizer)
      organizer.organized.each do |interactor|
        instance = double("#{interactor}")

        allow(interactor).to receive(:new).and_return(instance)
        allow(instance).to receive(:run!)
        allow(instance).to receive(:run)
        allow(instance).to receive(:context)
      end
    end
  end
end
