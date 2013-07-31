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
        context1 = Context.build(foo: "bar")
        context2 = Context.build(context1)

        expect(context2).to be_a(Context)
        expect {
          context2[:foo] = "baz"
        }.to change {
          context1[:foo]
        }.from("bar").to("baz")
      end
    end

    describe "#success?" do
      let(:context) { Context.build }

      it "is true by default" do
        expect(context.success?).to eq(true)
      end
    end

    describe "#failure?" do
      let(:context) { Context.build }

      it "is false by default" do
        expect(context.failure?).to eq(false)
      end
    end

    describe "#fail!" do
      let(:context) { Context.build }

      it "sets success to false" do
        expect {
          context.fail!
        }.to change {
          context.success?
        }.from(true).to(false)
      end

      it "sets failure to true" do
        expect {
          context.fail!
        }.to change {
          context.failure?
        }.from(false).to(true)
      end

      it "preserves failure" do
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
