shared_examples :lint do
  let(:interactor) { Class.new.send(:include, described_class) }

  describe ".call" do
    let(:context) { double(:context) }
    let(:instance) { double(:instance, context: context) }

    it "calls an instance with the given context" do
      expect(interactor).to receive(:new).once.with(foo: "bar") { instance }
      expect(instance).to receive(:call_with_hooks).once.with(no_args)

      expect(interactor.call(foo: "bar")).to eq(context)
    end

    it "provides a blank context if none is given" do
      expect(interactor).to receive(:new).once.with({}) { instance }
      expect(instance).to receive(:call_with_hooks).once.with(no_args)

      expect(interactor.call).to eq(context)
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

  describe ".before" do
    it "appends the given hook" do
      hook1 = proc { }

      expect {
        interactor.before(&hook1)
      }.to change {
        interactor.before_hooks
      }.from([]).to([hook1])

      hook2 = proc { }

      expect {
        interactor.before(&hook2)
      }.to change {
        interactor.before_hooks
      }.from([hook1]).to([hook1, hook2])
    end

    it "accepts method names" do
      expect {
        interactor.before(:hook1, :hook2)
      }.to change {
        interactor.before_hooks
      }.from([]).to([:hook1, :hook2])
    end
  end

  describe ".after" do
    it "prepends the given hook" do
      hook1 = proc { }

      expect {
        interactor.after(&hook1)
      }.to change {
        interactor.after_hooks
      }.from([]).to([hook1])

      hook2 = proc { }

      expect {
        interactor.after(&hook2)
      }.to change {
        interactor.after_hooks
      }.from([hook1]).to([hook2, hook1])
    end

    it "accepts method names" do
      expect {
        interactor.after(:hook1, :hook2)
      }.to change {
        interactor.after_hooks
      }.from([]).to([:hook2, :hook1])
    end
  end

  describe "#before_hooks" do
    it "is empty by default" do
      expect(interactor.before_hooks).to eq([])
    end
  end

  describe "#after_hooks" do
    it "is empty by default" do
      expect(interactor.after_hooks).to eq([])
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

  describe "#call_with_hooks" do
    let(:instance) { interactor.new(hooks: []) }
    let(:before1) { proc { context.hooks << :before1 } }
    let(:call) { proc { context.hooks << :call } }
    let(:after1) { proc { context.hooks << :after1 } }

    before do
      interactor.class_eval do
        private

        def before2
          context.hooks << :before2
        end

        def after2
          context.hooks << :after2
        end
      end
      interactor.stub(:before_hooks) { [before1, :before2] }
      instance.stub(:call) { instance.instance_eval(&call) }
      interactor.stub(:after_hooks) { [after1, :after2] }
    end

    it "runs before hooks, call, then after hooks" do
      expect {
        instance.call_with_hooks
      }.to change {
        instance.context.hooks
      }.from([]).to([:before1, :before2, :call, :after1, :after2])
    end

    context "when a before hook fails" do
      let(:before1) { proc { context.fail!; context.hooks << :before1 } }

      it "aborts" do
        expect {
          instance.call_with_hooks
        }.not_to change {
          instance.context.hooks
        }
      end
    end

    context "when a before hook errors" do
      let(:before1) { proc { raise "foo"; context.hooks << :before1 } }

      it "aborts" do
        expect {
          instance.call_with_hooks rescue nil
        }.not_to change {
          instance.context.hooks
        }
      end

      it "raises the error" do
        expect {
          instance.call_with_hooks
        }.to raise_error("foo")
      end
    end

    context "when call fails" do
      let!(:call) { proc { context.fail!; context.hooks << :call } }

      it "aborts" do
        expect {
          instance.call_with_hooks
        }.to change {
          instance.context.hooks
        }.from([]).to([:before1, :before2])
      end
    end

    context "when call errors" do
      let!(:call) { proc { raise "foo"; context.hooks << :call } }

      it "aborts" do
        expect {
          instance.call_with_hooks rescue nil
        }.to change {
          instance.context.hooks
        }.from([]).to([:before1, :before2])
      end

      it "raises the error" do
        expect {
          instance.call_with_hooks
        }.to raise_error("foo")
      end
    end

    context "when an after hook fails" do
      let(:after1) { proc { context.fail!; context.hooks << :after1 } }

      it "aborts" do
        expect {
          instance.call_with_hooks
        }.to change {
          instance.context.hooks
        }.from([]).to([:before1, :before2, :call])
      end

      it "rolls back"
    end

    context "when an after hook errors" do
      let(:after1) { proc { raise "foo"; context.hooks << :after1 } }

      it "aborts" do
        expect {
          instance.call_with_hooks rescue nil
        }.to change {
          instance.context.hooks
        }.from([]).to([:before1, :before2, :call])
      end

      it "rolls back"

      it "raises the error" do
        expect {
          instance.call_with_hooks
        }.to raise_error("foo")
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
