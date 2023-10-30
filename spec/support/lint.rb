shared_examples :lint do
  let(:interactor) { Class.new.send(:include, described_class) }

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

  describe "#run" do
    let(:instance) { interactor.new }

    it "runs the interactor" do
      expect(instance).to receive(:run!).once.with(no_args)

      instance.run
    end

    it "rescues failure with the same context" do
      expect(instance).to receive(:run!).and_raise(Interactor::Failure.new(instance.context))

      expect {
        instance.run
      }.not_to raise_error
    end

    it "raises other errors" do
      expect(instance).to receive(:run!).and_raise("foo")

      expect {
        instance.run
      }.to raise_error("foo")
    end
  end

  describe "#run!" do
    let(:instance) { interactor.new }

    it "calls the interactor" do
      expect(instance).to receive(:call).once.with(no_args)

      instance.run!
    end

    it "raises failure" do
      expect(instance).to receive(:run!).and_raise(Interactor::Failure)

      expect {
        instance.run!
      }.to raise_error(Interactor::Failure)
    end

    it "raises other errors" do
      expect(instance).to receive(:run!).and_raise("foo")

      expect {
        instance.run
      }.to raise_error("foo")
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
