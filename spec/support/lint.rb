shared_examples :lint do
  let(:interactor) { Class.new.send(:include, described_class) }

  describe ".perform" do
    let(:instance) { double(:instance) }

    it "performs an instance with the given context" do
      expect(interactor).to receive(:new).once.with(foo: "bar") { instance }
      expect(instance).to receive(:perform).once.with(no_args)

      expect(interactor.perform(foo: "bar")).to eq(instance)
    end

    it "provides a blank context if none is given" do
      expect(interactor).to receive(:new).once.with({}) { instance }
      expect(instance).to receive(:perform).once.with(no_args)

      expect(interactor.perform).to eq(instance)
    end
  end

  describe ".perform!" do
    let(:instance) { double(:instance) }

    it "performs an instance with the given context!" do
      expect(interactor).to receive(:new).once.with(foo: "bar") { instance }
      expect(instance).to receive(:perform!).once.with(no_args)

      expect(interactor.perform!(foo: "bar")).to eq(instance)
    end

    it "provides a blank context if none is given" do
      expect(interactor).to receive(:new).once.with({}) { instance }
      expect(instance).to receive(:perform!).once.with(no_args)

      expect(interactor.perform!).to eq(instance)
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
  end

  describe "#perform" do
    let(:instance) { interactor.new }

    it "performs!" do
      expect(instance).to receive(:perform!).once.with(no_args)

      instance.perform
    end

    it "rescues failure" do
      expect(instance).to receive(:perform!).and_raise(Interactor::Failure)

      expect { instance.perform }.not_to raise_error
    end

    it "doesn't rescue other errors" do
      error = StandardError.new

      expect(instance).to receive(:setup)
      expect(instance).to receive(:run).and_raise(error)

      expect { instance.perform }.to raise_error(error)
    end
  end

  describe "#perform!" do
    let(:instance) { interactor.new }

    it "sets up and runs" do
      expect(instance).to receive(:setup).once.with(no_args).ordered
      expect(instance).to receive(:run).once.with(no_args).ordered

      instance.perform!
    end

    it "rescues setup success" do
      expect(instance).to receive(:setup).and_raise(Interactor::Success)
      expect(instance).not_to receive(:run)

      expect { instance.perform! }.not_to raise_error
    end

    it "doesn't rescue setup failure" do
      error = Interactor::Failure.new

      expect(instance).to receive(:setup).and_raise(error)
      expect(instance).not_to receive(:run)

      expect { instance.perform! }.to raise_error(error)
    end

    it "rescues run success" do
      expect(instance).to receive(:setup)
      expect(instance).to receive(:run).and_raise(Interactor::Success)

      expect { instance.perform! }.not_to raise_error
    end

    it "doesn't rescue run failure" do
      error = Interactor::Failure.new

      expect(instance).to receive(:setup)
      expect(instance).to receive(:run).and_raise(error)

      expect { instance.perform! }.to raise_error(error)
    end

    it "doesn't rescue other errors" do
      error = StandardError.new

      expect(instance).to receive(:setup)
      expect(instance).to receive(:run).and_raise(error)

      expect { instance.perform! }.to raise_error(error)
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

  describe "#run" do
    let(:instance) { interactor.new }

    it "exists" do
      expect(instance).to respond_to(:run)
      expect { instance.run }.not_to raise_error
      expect { instance.method(:run) }.not_to raise_error
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

    it "raises a failure" do
      expect { instance.fail! }.to raise_error(Interactor::Failure)
    end

    it "interrupts execution" do
      interactor.class_eval do
        def setup
          context[:foo] = "bar"
          fail!
          context[:foo] = "baz"
        end
      end

      instance.setup rescue nil

      expect(context[:foo]).to eq("bar")
    end

    it "defers to the context" do
      expect(context).to receive(:fail!).once.with(no_args)

      instance.fail! rescue nil
    end

    it "passes updates to the context" do
      expect(context).to receive(:fail!).once.with(foo: "bar")

      instance.fail!(foo: "bar") rescue nil
    end
  end

  describe "#succeed!" do
    let(:instance) { interactor.new }
    let(:context) { instance.context }

    it "raises a success" do
      expect { instance.succeed! }.to raise_error(Interactor::Success)
    end

    it "interrupts execution" do
      interactor.class_eval do
        def setup
          context[:foo] = "bar"
          succeed!
          context[:foo] = "baz"
        end
      end

      instance.setup rescue nil

      expect(context[:foo]).to eq("bar")
    end

    it "defers to the context" do
      expect(context).to receive(:succeed!).once.with(no_args)

      instance.succeed! rescue nil
    end

    it "passes updates to the context" do
      expect(context).to receive(:succeed!).once.with(foo: "bar")

      instance.succeed!(foo: "bar") rescue nil
    end
  end

  describe "context deferral" do
    context "initialized" do
      let(:instance) { interactor.new(foo: "bar", "hello" => "world") }

      it "defers to keys that exist in the context" do
        expect(instance).to respond_to(:foo)
        expect(instance.foo).to eq("bar")
        expect { instance.method(:foo) }.not_to raise_error
      end

      it "defers to string keys that exist in the context" do
        expect(instance).to respond_to(:hello)
        expect(instance.hello).to eq("world")
        expect { instance.method(:hello) }.not_to raise_error
      end

      it "bombs if the key does not exist in the context" do
        expect(instance).not_to respond_to(:baz)
        expect { instance.baz }.to raise_error(NoMethodError)
        expect { instance.method(:baz) }.to raise_error(NameError)
      end
    end

    context "allocated" do
      let(:instance) { interactor.allocate }

      it "doesn't respond to context keys before the context is set" do
        expect(instance).not_to respond_to(:foo)
      end
    end
  end
end
