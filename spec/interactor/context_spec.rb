require "spec_helper"

module Interactor
  describe Context do
    describe ".build" do
      it "converts the given hash to a context" do
        context = Context.build(foo: "bar")

        expect(context).to be_a(Context)
        expect(context).to eq(foo: "bar")
      end

      it "builds an empty context if no hash is given" do
        context = Context.build

        expect(context).to be_a(Context)
        expect(context).to eq({})
      end

      it "preserves an already built context" do
        context1 = Context.build
        context2 = Context.build(context1)

        expect(context2).to be_a(Context)
        expect {
          context2[:foo] = "bar"
        }.to change {
          context1[:foo]
        }.from(nil).to("bar")
      end
    end

    describe "#success?" do
      it "is true by default" do
        context = Context.build

        expect(context.success?).to eq(true)
      end
    end

    describe "#failure?" do
      it "is false by default" do
        context = Context.build

        expect(context.failure?).to eq(false)
      end
    end

    describe "#fail!" do
      it "sets success to false" do
        context = Context.build

        expect {
          context.fail!
        }.to change {
          context.success?
        }.from(true).to(false)
      end

      it "sets failure to true" do
        context = Context.build

        expect {
          context.fail!
        }.to change {
          context.failure?
        }.from(false).to(true)
      end

      it "preserves failure" do
        context = Context.build
        context.fail!

        expect {
          context.fail!
        }.not_to change {
          context.failure?
        }
      end
    end
  end
end
