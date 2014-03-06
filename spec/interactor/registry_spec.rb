require "spec_helper"

module Interactor
  describe Registry do

    before :all do
      ::DoSomething = Class.new.send(:include, Interactor)
      ::User = Module.new
      ::User.const_set('Login', Class.new.send(:include, Interactor))
    end

    let(:registry) { Interactor.registry }

    context "when a valid interactor is available" do
      it "should respond" do
        expect(registry.respond_to?(:do_something)).to be_true
      end

      it "should perform the interactor" do
        expect(registry.do_something).to be_instance_of ::DoSomething
      end

      it "should allow dot notation" do
        expect(registry.user.respond_to?(:login)).to be_true
      end
    end

    context "when no valid interactor is available" do
      it "should not respond" do
        expect(registry.respond_to?(:not_registered)).to be_false
      end

      it "should raise NoMethodError" do
        expect{ registry.not_registered }.to raise_error NoMethodError
      end
    end

  end
end
