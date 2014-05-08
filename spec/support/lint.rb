shared_examples :lint do
  let(:interactor) { Class.new.send(:include, described_class) }

  describe ".call" do
    let(:instance) { double(:instance, context: context) }

    context "when setup succeeds" do
      let(:context) { double(:context, success?: true, failure?: false) }

      it "calls an instance with the given context" do
        expect(interactor).to receive(:new).once.with(foo: "bar") { instance }
        expect(instance).to receive(:call).once.with(no_args)

        expect(interactor.call(foo: "bar")).to eq(context)
      end

      it "provides a blank context if none is given" do
        expect(interactor).to receive(:new).once.with({}) { instance }
        expect(instance).to receive(:call).once.with(no_args)

        expect(interactor.call).to eq(context)
      end
    end

    context "when setup fails" do
      let(:context) { double(:context, success?: false, failure?: true) }

      it "does not call the instance" do
        expect(interactor).to receive(:new).once { instance }
        instance.stub(failure?: true)

        expect(instance).not_to receive(:call)

        expect(interactor.call).to eq(context)
      end
    end
  end

  describe ".rollback" do
    let(:context) { double(:context) }
    let(:instance) { double(:instance, context: context) }

    it "rolls back an instance with the given context" do
      expect(interactor).to receive(:new).once.with(foo: "bar") { instance }
      expect(instance).to receive(:rollback).once.with(no_args)

      expect(interactor.rollback(foo: "bar")).to eq(context)
    end

    it "provides a blank context if none is given" do
      expect(interactor).to receive(:new).once.with({}) { instance }
      expect(instance).to receive(:rollback).once.with(no_args)

      expect(interactor.rollback).to eq(context)
    end
  end

  describe ".new" do
    let(:context) { double(:context) }

    it "initializes a context" do
      expect(Interactor::Context).to receive(:build).once.with(foo: "bar") { context }

      instance = interactor.new(foo: "bar")

      expect(instance).to be_a(interactor)
      expect(instance.context).to eq(context)
    end

    it "initializes a blank context if none is given" do
      expect(Interactor::Context).to receive(:build).once.with({}) { context }

      instance = interactor.new

      expect(instance).to be_a(interactor)
      expect(instance.context).to eq(context)
    end

    it "calls setup" do
      interactor.class_eval do
        def setup
          context.foo = context.bar
        end
      end

      instance = interactor.new(bar: "baz")

      expect(instance.context.foo).to eq("baz")
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

  describe "#call" do
    let(:instance) { interactor.new }

    it "exists" do
      expect(instance).to respond_to(:call)
      expect { instance.call }.not_to raise_error
      expect { instance.method(:call) }.not_to raise_error
    end
  end

  describe "#rollback" do
    let(:instance) { interactor.new }

    it "exists" do
      expect(instance).to respond_to(:rollback)
      expect { instance.rollback }.not_to raise_error
      expect { instance.method(:rollback) }.not_to raise_error
    end
  end
end
