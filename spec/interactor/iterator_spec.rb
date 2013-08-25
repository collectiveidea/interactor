require "spec_helper"

module Interactor
  describe Iterator do
    include_examples :lint

    let(:iterator) { Class.new.send(:include, Iterator) }

    describe ".collection" do
      it "is nil by default" do
        expect(iterator.collection).to be_nil
      end
    end

    describe ".collect" do
      it "sets collection" do
        expect {
          iterator.collect(:elements)
        }.to change {
          iterator.collection
        }.from(nil).to(:elements)
      end
    end

    describe "#collection" do
      let(:instance) { iterator.new(elements: [1, 2, 3]) }

      it "is empty by default" do
        expect(instance.collection).to eq([])
      end

      it "returns the collection from the context" do
        iterator.stub(collection: :elements)

        expect(instance.collection).to eq([1, 2, 3])
      end
    end

    describe "#perform" do
      let(:instance) { iterator.new(elements: [1, 2, 3]) }
      let(:context) { instance.context }

      before do
        iterator.stub(collection: :elements)
      end

      it "performs each element in order" do
        expect(instance).to receive(:perform_each).once.with(1).ordered
        expect(instance).to receive(:perform_each).once.with(2).ordered
        expect(instance).to receive(:perform_each).once.with(3).ordered

        expect(instance).not_to receive(:rollback)

        instance.perform
      end

      it "builds up the performed elements" do
        instance.stub(:perform_each).with(1) do
          expect(instance.performed).to eq([])
        end

        instance.stub(:perform_each).with(2) do
          expect(instance.performed).to eq([1])
        end

        instance.stub(:perform_each).with(3) do
          expect(instance.performed).to eq([1, 2])
        end

        expect {
          instance.perform
        }.to change {
          instance.performed
        }.from([]).to([1, 2, 3])
      end

      it "aborts and rolls back on failure" do
        expect(instance).to receive(:perform_each).once.with(1).ordered
        expect(instance).to receive(:perform_each).once.with(2).ordered { context.fail! }
        expect(instance).not_to receive(:perform_each).with(3)

        expect(instance).to receive(:rollback).once.ordered do
          expect(instance.performed).to eq([1])
        end

        instance.perform
      end
    end

    describe "#rollback" do
      let(:instance) { iterator.new }

      before do
        instance.stub(:performed) { [1, 2] }
      end

      it "rolls back each performed element in reverse" do
        expect(instance).to receive(:rollback_each).once.with(2).ordered
        expect(instance).to receive(:rollback_each).once.with(1).ordered

        instance.rollback
      end
    end

    describe "#performed" do
      let(:instance) { iterator.new }

      it "is empty by default" do
        expect(instance.performed).to eq([])
      end
    end

    describe "#perform_each" do
      let(:instance) { iterator.new }

      it "exists" do
        expect(instance).to respond_to(:perform_each)
        expect { instance.perform_each }.not_to raise_error
        expect { instance.method(:perform_each) }.not_to raise_error
      end
    end

    describe "#rollback_each" do
      let(:instance) { iterator.new }

      it "exists" do
        expect(instance).to respond_to(:rollback_each)
        expect { instance.rollback_each }.not_to raise_error
        expect { instance.method(:rollback_each) }.not_to raise_error
      end
    end
  end
end
