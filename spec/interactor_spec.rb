require "spec_helper"

describe Interactor do
  let(:interactor) { Class.new { include Interactor } }

  describe ".perform" do
    let(:instance) { double(:instance) }

    it "performs an instance with the given context" do
      expect(interactor).to receive(:new).with(foo: "bar") { instance }
      expect(instance).to receive(:perform).once.with(no_args)

      expect(interactor.perform(foo: "bar")).to eq(instance)
    end

    it "provides a blank context if none is given" do
      expect(interactor).to receive(:new).with({}) { instance }
      expect(instance).to receive(:perform).once.with(no_args)

      expect(interactor.perform).to eq(instance)
    end
  end

  describe ".new" do
    let(:context) { double(:context) }

    it "initializes a context" do
      expect(Interactor::Context).to receive(:build).with(foo: "bar") { context }

      instance = interactor.new(foo: "bar")

      expect(instance.context).to eq(context)
    end

    it "initializes a blank context if none is given" do
      expect(Interactor::Context).to receive(:build).with({}) { context }

      instance = interactor.new

      expect(instance.context).to eq(context)
    end
  end

  describe ".interactors" do
    it "is empty by default" do
      expect(interactor.interactors).to eq([])
    end
  end

  describe ".organize" do
    it "sets interactors given class arguments" do
      expect {
        interactor.organize(String, Integer)
      }.to change {
        interactor.interactors
      }.from([]).to([String, Integer])
    end

    it "sets interactors given an array of classes" do
      expect {
        interactor.organize([String, Integer])
      }.to change {
        interactor.interactors
      }.from([]).to([String, Integer])
    end
  end
end
