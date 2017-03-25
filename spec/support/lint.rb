shared_examples :lint do
  let(:interactor) { Class.new.send(:include, described_class) }

  let(:context_double) do
    double(:double, failure?: false, called!: nil, rollback!: nil)
  end

  let(:failed_context_double) do
    double(:failed_context_double, failure?: true, called!: nil, rollback!: nil)
  end

  describe ".call" do
    let(:context) { double(:context) }
    let(:instance) { double(:instance, context: context) }

    it "calls an instance with the given context" do
      expect(interactor).to receive(:new).once.with(foo: "bar") { instance }
      expect(instance).to receive(:run).once.with(no_args)

      expect(interactor.call(foo: "bar")).to eq(context)
    end

    it "provides a blank context if none is given" do
      expect(interactor).to receive(:new).once.with({}) { instance }
      expect(instance).to receive(:run).once.with(no_args)

      expect(interactor.call).to eq(context)
    end
  end

  describe ".call!" do
    let(:context) { double(:context) }
    let(:instance) { double(:instance, context: context) }

    it "calls an instance with the given context" do
      expect(interactor).to receive(:new).once.with(foo: "bar") { instance }
      expect(instance).to receive(:run!).once.with(no_args)

      expect(interactor.call!(foo: "bar")).to eq(context)
    end

    it "provides a blank context if none is given" do
      expect(interactor).to receive(:new).once.with({}) { instance }
      expect(instance).to receive(:run!).once.with(no_args)

      expect(interactor.call!).to eq(context)
    end
  end

  describe ".new" do
    let(:context) { double(:context) }

    it "initializes a context" do
      expect(Interactor::Context).to receive(:build)
        .once.with(foo: "bar") { context }

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

  describe "#run" do
    let(:instance) { interactor.new }

    it "runs the interactor" do
      expect(instance).to receive(:call).once.with(no_args)

      instance.run
    end

    it "catches :early_return" do
      allow(instance).to receive(:call).and_throw(:early_return)
      expect {
        instance.run
      }.not_to throw_symbol
    end

    context "when error is raised inside #call" do
      it "propagates it and rollbacks context" do
        allow(instance).to receive(:context) { context_double }
        allow(instance).to receive(:call).and_raise("foo")

        expect(instance.context).to receive(:rollback!)
        expect {
          instance.run
        }.to raise_error("foo")
      end
    end

    context "on call failure" do
      before do
        allow(instance).to receive(:context) { failed_context_double }
      end

      it "doesn't raise Failure" do
        expect {
          instance.run
        }.not_to raise_error
      end

      it "rollbacks context on error" do
        expect(instance.context).to receive(:rollback!)
        instance.run
      end
    end
  end

  describe "#run!" do
    let(:instance) { interactor.new }

    it "calls the interactor" do
      expect(instance).to receive(:run).once.with(no_args)

      instance.run!
    end

    it "propagates errors" do
      expect(instance).to receive(:run).and_raise("foo")

      expect {
        instance.run
      }.to raise_error("foo")
    end

    context "on failure" do
      before do
        allow(instance).to receive(:context) { failed_context_double }
      end

      it "raises Interactor::Failure" do
        expect {
          instance.run!
        }.to raise_error(Interactor::Failure)
      end

      it "makes context available from the error" do
        begin
          instance.run!
        rescue Interactor::Failure => error
          expect(error.context).to be(instance.context)
        end
      end
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
