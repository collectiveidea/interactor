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

      expect(instance).to be_a(Interactor)
      expect(instance.context).to eq(context)
    end

    it "initializes a blank context if none is given" do
      expect(Interactor::Context).to receive(:build).with({}) { context }

      instance = interactor.new

      expect(instance).to be_a(Interactor)
      expect(instance.context).to eq(context)
    end
  end

  describe ".interactors" do
    it "is empty by default" do
      expect(interactor.interactors).to eq([])
    end
  end

  describe ".organize" do
    let(:interactor2) { double(:interactor2) }
    let(:interactor3) { double(:interactor3) }

    it "sets interactors given class arguments" do
      expect {
        interactor.organize(interactor2, interactor3)
      }.to change {
        interactor.interactors
      }.from([]).to([interactor2, interactor3])
    end

    it "sets interactors given an array of classes" do
      expect {
        interactor.organize([interactor2, interactor3])
      }.to change {
        interactor.interactors
      }.from([]).to([interactor2, interactor3])
    end
  end

  describe ".rollback" do
    let(:instance) { double(:instance) }

    it "rolls back an instance with the given context" do
      expect(interactor).to receive(:new).with(foo: "bar") { instance }
      expect(instance).to receive(:rollback).once.with(no_args)

      expect(interactor.rollback(foo: "bar")).to eq(instance)
    end

    it "provides a blank context if none is given" do
      expect(interactor).to receive(:new).with({}) { instance }
      expect(instance).to receive(:rollback).once.with(no_args)

      expect(interactor.rollback).to eq(instance)
    end
  end

  describe "#interactors" do
    let(:interactors) { double(:interactors) }
    let(:instance) { interactor.new }

    before do
      interactor.stub(:interactors) { interactors }
    end

    it "defers to the class" do
      expect(instance.interactors).to eq(interactors)
    end
  end

  describe "#perform" do
    let(:interactor2) { double(:interactor2) }
    let(:interactor3) { double(:interactor3) }
    let(:interactor4) { double(:interactor4) }
    let(:instance) { interactor.new }
    let(:context) { instance.context }

    before do
      interactor.stub(:interactors) { [interactor2, interactor3, interactor4] }
    end

    it "performs each interactor in order with the context" do
      expect(interactor2).to receive(:perform).once.with(context).ordered
      expect(interactor3).to receive(:perform).once.with(context).ordered
      expect(interactor4).to receive(:perform).once.with(context).ordered

      expect(instance).not_to receive(:rollback)

      instance.perform
    end

    it "builds up the performed interactors" do
      interactor2.stub(:perform) do
        expect(instance.performed).to eq([interactor2])
      end

      interactor3.stub(:perform) do
        expect(instance.performed).to eq([interactor2, interactor3])
      end

      interactor4.stub(:perform) do
        expect(instance.performed).to eq([interactor2, interactor3, interactor4])
      end

      expect {
        instance.perform
      }.to change {
        instance.performed
      }.from([]).to([interactor2, interactor3, interactor4])
    end

    it "aborts and rolls back on failure" do
      expect(interactor2).to receive(:perform).once.with(context).ordered
      expect(interactor3).to receive(:perform).once.with(context).ordered { context.fail! }
      expect(interactor4).not_to receive(:perform)

      expect(instance).to receive(:rollback).once.ordered do
        expect(instance.performed).to eq([interactor2, interactor3])
      end

      instance.perform
    end
  end

  describe "#rollback" do
    let(:interactor2) { double(:interactor2) }
    let(:interactor3) { double(:interactor3) }
    let(:interactor4) { double(:interactor4) }
    let(:instance) { interactor.new }
    let(:context) { instance.context }

    before do
      interactor.stub(:interactors) { [interactor2, interactor3, interactor4] }
      instance.stub(:performed) { [interactor2, interactor3] }
    end

    it "rolls back each performed interactor in reverse" do
      expect(interactor4).not_to receive(:rollback)
      expect(interactor3).to receive(:rollback).once.with(context).ordered
      expect(interactor2).to receive(:rollback).once.with(context).ordered

      instance.rollback
    end
  end

  describe "#performed" do
    let(:instance) { interactor.new }

    it "is empty by default" do
      expect(instance.performed).to eq([])
    end
  end
end
