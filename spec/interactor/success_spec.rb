require "spec_helper"


module Interactor
  describe Success do
    let(:instance) { double(:instance, success?: true) }
    let(:failed_instance) { double(:failed_instance, success?: false) }


    it "performs in case of success" do
      success = Success.new instance
      result = nil
      success.perform do
        result = :success
      end
      expect(result).to eq(:success)
    end

    it "doen't performs in case of failure" do
      success = Success.new failed_instance
      result = nil
      success.perform do
        result = :failure
      end
      expect(result).to eq(nil)
    end
  end
end
