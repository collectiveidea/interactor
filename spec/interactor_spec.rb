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

    it "calls setup" do
      interactor.class_eval do
        def setup
          context[:foo] = bar
        end
      end

      instance = interactor.new(bar: "baz")

      expect(instance.context[:foo]).to eq("baz")
    end
  end

  describe "#setup" do
    let(:instance) { interactor.new }

    it "exists" do
      expect(instance).to respond_to(:setup)
      expect { instance.setup }.not_to raise_error
      expect { instance.method(:setup) }.not_to raise_error
    end
  end

  describe "#success?" do
    let(:instance) { interactor.new }
    let(:context) { instance.context }

    it "defers to the context" do
      context.stub(success?: true)
      expect(instance.success?).to eq(true)

      context.stub(success?: false)
      expect(instance.success?).to eq(false)
    end
  end

  describe "#failure?" do
    let(:instance) { interactor.new }
    let(:context) { instance.context }

    it "defers to the context" do
      context.stub(failure?: true)
      expect(instance.failure?).to eq(true)

      context.stub(failure?: false)
      expect(instance.failure?).to eq(false)
    end
  end

  describe "#fail!" do
    let(:instance) { interactor.new }
    let(:context) { instance.context }

    it "defers to the context" do
      expect(context).to receive(:fail!).with(no_args)

      instance.fail!
    end

    it "passes updates to the context" do
      expect(context).to receive(:fail!).with(foo: "bar")

      instance.fail!(foo: "bar")
    end
  end

  describe "context deferral" do
    let(:instance) { interactor.new(foo: "bar") }

    it "defers to keys that exist in the context" do
      expect(instance).to respond_to(:foo)
      expect(instance.foo).to eq("bar")
      expect { instance.method(:foo) }.not_to raise_error
    end

    it "bombs if the key does not exist in the context" do
      expect(instance).not_to respond_to(:baz)
      expect { instance.baz }.to raise_error(NoMethodError)
      expect { instance.method(:baz) }.to raise_error(NameError)
    end
  end
end
