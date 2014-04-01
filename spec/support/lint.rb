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

    it "runs with #before_run and #after_run" do
      expect(instance).to receive(:before_run).once.with(no_args).ordered
      expect(instance).to receive(:run).once.with(no_args).ordered
      expect(instance).to receive(:after_run).once.with(no_args).ordered

      instance.perform
    end

    context "with neither #succeed! nor #fail!" do
      it "is a success" do
        instance.perform

        expect(instance.success?).to be_true
      end

      it "doesn't roll back" do
        expect(instance).not_to receive(:rollback)

        instance.perform
      end
    end

    context "with #succeed!" do
      it "is a success" do
        instance.extend(Module.new { def run; succeed!; end })
        instance.perform

        expect(instance.success?).to be_true
      end

      it "halts further execution" do
        instance.extend(Module.new { def foobar; raise "can't be here!"; end })
        instance.extend(Module.new { def before_run; succeed!; foobar; end })
        expect(instance).not_to receive(:run)
        expect(instance).not_to receive(:foobar)
        expect(instance).not_to receive(:after_run)

        instance.perform
      end

      it "doesn't roll back" do
        instance.extend(Module.new { def run; succeed!; end })
        expect(instance).not_to receive(:rollback)

        instance.perform
      end
    end

    context "with #fail!" do
      it "is a failure" do
        instance.extend(Module.new { def run; fail!; end })
        instance.perform

        expect(instance.failure?).to be_true
      end

      it "halts further execution" do
        instance.extend(Module.new { def foobar; raise "can't be here!"; end })
        instance.extend(Module.new { def before_run; fail!; foobar; end })
        expect(instance).not_to receive(:run)
        expect(instance).not_to receive(:foobar)
        expect(instance).not_to receive(:after_run)

        instance.perform
      end

      it "doesn't roll back" do
        instance.extend(Module.new { def run; fail!; end })
        expect(instance).not_to receive(:rollback)

        instance.perform
      end

      context "during #after_run" do
        it "rolls back" do
          instance.extend(Module.new { def after_run; fail!; end })
          expect(instance).to receive(:rollback)

          instance.perform
        end
      end
    end
  end

  describe "#perform!" do
    let(:instance) { interactor.new }

    it "performs" do
      expect(instance).to receive(:perform).once.with(no_args)

      instance.perform!
    end

    context "with #fail!" do
      it "raises Interactor::Failure" do
        instance.extend(Module.new { def run; fail!; end })

        expect { instance.perform! }.to raise_error(Interactor::Failure)
      end
    end
  end
end
