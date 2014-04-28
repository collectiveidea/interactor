shared_examples :lint do
  let(:interactor) { Class.new.send(:include, described_class) }

  describe ".perform" do
    let(:instance) { double(:instance, failure?: false) }

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

    it "does not run perform if the context is a failure after setup" do
      expect(interactor).to receive(:new).once { instance }
      instance.stub(failure?: true)

      expect(instance).not_to receive(:perform)

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

      expect(instance).to receive(:before)
      expect(instance).to receive(:run).and_raise(error)

      expect { instance.perform }.to raise_error(error)
    end
  end

  describe "#perform!" do
    let(:instance) { interactor.new }

    it "runs with before and after" do
      expect(instance).to receive(:before).once.with(no_args).ordered
      expect(instance).to receive(:run).once.with(no_args).ordered
      expect(instance).to receive(:after).once.with(no_args).ordered

      instance.perform!
    end

    context "with hard success" do
      let(:error) { Interactor::Success.new }

      context "before run" do
        before do
          instance.stub(:before).and_raise(error)
          expect(instance).not_to receive(:run)
          expect(instance).not_to receive(:after)
        end

        it "rescues" do
          expect { instance.perform! }.not_to raise_error
        end

        it "doesn't roll back" do
          expect(instance).not_to receive(:rollback)

          instance.perform!
        end
      end

      context "during run" do
        before do
          instance.stub(:run).and_raise(error)
          expect(instance).not_to receive(:after)
        end

        it "rescues" do
          expect { instance.perform! }.not_to raise_error
        end

        it "doesn't roll back" do
          expect(instance).not_to receive(:rollback)

          instance.perform!
        end
      end

      context "after run" do
        before do
          instance.stub(:after).and_raise(error)
        end

        it "rescues" do
          expect { instance.perform! }.not_to raise_error
        end

        it "doesn't roll back" do
          expect(instance).not_to receive(:rollback)

          instance.perform!
        end
      end
    end

    context "with failure" do
      let(:error) { Interactor::Failure.new }

      context "before run" do
        before do
          instance.stub(:before).and_raise(error)
          expect(instance).not_to receive(:run)
          expect(instance).not_to receive(:after)
        end

        it "doesn't rescue" do
          expect { instance.perform! }.to raise_error(error)
        end

        it "doesn't roll back" do
          expect(instance).not_to receive(:rollback)

          instance.perform! rescue nil
        end
      end

      context "during run" do
        before do
          instance.stub(:run).and_raise(error)
          expect(instance).not_to receive(:after)
        end

        it "doesn't rescue" do
          expect { instance.perform! }.to raise_error(error)
        end

        it "doesn't roll back" do
          expect(instance).not_to receive(:rollback)

          instance.perform! rescue nil
        end
      end

      context "after run" do
        before do
          instance.stub(:after).and_raise(error)
        end

        it "doesn't rescue" do
          expect { instance.perform! }.to raise_error(error)
        end

        it "rolls back" do
          expect(instance).to receive(:after).and_raise(error).ordered
          expect(instance).to receive(:rollback).once.with(no_args).ordered

          instance.perform! rescue nil
        end
      end
    end

    context "with some other error" do
      let(:error) { StandardError.new }

      context "before run" do
        before do
          instance.stub(:before).and_raise(error)
          expect(instance).not_to receive(:run)
          expect(instance).not_to receive(:after)
        end

        it "doesn't rescue" do
          expect { instance.perform! }.to raise_error(error)
        end

        it "doesn't roll back" do
          expect(instance).not_to receive(:rollback)

          instance.perform! rescue nil
        end
      end

      context "during run" do
        before do
          instance.stub(:run).and_raise(error)
          expect(instance).not_to receive(:after)
        end

        it "doesn't rescue" do
          expect { instance.perform! }.to raise_error(error)
        end

        it "doesn't roll back" do
          expect(instance).not_to receive(:rollback)

          instance.perform! rescue nil
        end
      end

      context "after run" do
        before do
          instance.stub(:after).and_raise(error)
        end

        it "doesn't rescue" do
          expect { instance.perform! }.to raise_error(error)
        end

        it "rolls back" do
          expect(instance).to receive(:after).and_raise(error).ordered
          expect(instance).to receive(:rollback).once.with(no_args).ordered

          instance.perform! rescue nil
        end
      end
    end
  end

  describe "#before" do
    let(:instance) { interactor.new }

    it "exists" do
      expect(instance).to respond_to(:before)
      expect { instance.before }.not_to raise_error
      expect { instance.method(:before) }.not_to raise_error
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

  describe "#after" do
    let(:instance) { interactor.new }

    it "exists" do
      expect(instance).to respond_to(:after)
      expect { instance.after }.not_to raise_error
      expect { instance.method(:after) }.not_to raise_error
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
        def run
          context[:foo] = "bar"
          fail!
          context[:foo] = "baz"
        end
      end

      instance.run rescue nil

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
        def run
          context[:foo] = "bar"
          succeed!
          context[:foo] = "baz"
        end
      end

      instance.run rescue nil

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
