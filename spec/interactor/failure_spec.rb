require "spec_helper"


module Interactor
  describe Failure do
    let(:failed_instance) { double(:failed_instance, failure?: true) }
    let(:instance) { double(:instance, failure?: false) }


    it "performs in case of failure" do
      failure = Failure.new failed_instance
      result = nil
      failure.perform do
        result = :failed
      end
      expect(result).to eq(:failed)
    end

    it "doen't performs in case of success" do
      failure = Failure.new instance
      result = nil
      failure.perform do
        result = :success
      end
      expect(result).to eq(nil)
    end
  end
end
