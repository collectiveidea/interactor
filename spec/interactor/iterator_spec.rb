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
      context "with an array collection" do
        let(:instance) { iterator.new(elements: [1, 2, 3]) }

        before do
          iterator.stub(collection: :elements)
        end

        it "performs each element in order with its index" do
          expect(instance).to receive(:perform_each).once.with(1, 0).ordered
          expect(instance).to receive(:perform_each).once.with(2, 1).ordered
          expect(instance).to receive(:perform_each).once.with(3, 2).ordered

          expect(instance).not_to receive(:rollback)

          instance.perform
        end

        it "builds up the performed elements" do
          instance.stub(:perform_each).with(1, 0) do
            expect(instance.performed).to eq([])
          end

          instance.stub(:perform_each).with(2, 1) do
            expect(instance.performed).to eq([[1, 0]])
          end

          instance.stub(:perform_each).with(3, 2) do
            expect(instance.performed).to eq([[1, 0], [2, 1]])
          end

          expect {
            instance.perform
          }.to change {
            instance.performed
          }.from([]).to([[1, 0], [2, 1], [3, 2]])
        end

        it "aborts and rolls back on failure" do
          expect(instance).to receive(:perform_each).once.with(1, 0).ordered
          expect(instance).to receive(:perform_each).once.with(2, 1).ordered { instance.fail! }
          expect(instance).not_to receive(:perform_each).with(3, 2)

          expect(instance).to receive(:rollback).once.ordered do
            expect(instance.performed).to eq([[1, 0]])
          end

          instance.perform
        end

        context "with perform_each accepting one argument" do
          before do
            instance.context[:args] = []

            iterator.class_eval do
              def perform_each(element)
                context[:args] << [element]
              end
            end
          end

          it "excludes the index from the arguments" do
            expect {
              instance.perform
            }.to change {
              instance.context[:args]
            }.from([]).to([[1], [2], [3]])
          end

          it "includes the index in the performed elements" do
            expect {
              instance.perform
            }.to change {
              instance.performed
            }.from([]).to([[1, 0], [2, 1], [3, 2]])
          end
        end
      end

      context "with a hash collection" do
        let(:instance) { iterator.new(pairs: {one: 1, two: 2, three: 3}) }

        before do
          iterator.stub(collection: :pairs)
        end

        it "performs each key/value pair in order" do
          expect(instance).to receive(:perform_each).once.with(:one, 1, 0).ordered
          expect(instance).to receive(:perform_each).once.with(:two, 2, 1).ordered
          expect(instance).to receive(:perform_each).once.with(:three, 3, 2).ordered

          expect(instance).not_to receive(:rollback)

          instance.perform
        end

        it "builds up the performed elements" do
          instance.stub(:perform_each).with(:one, 1, 0) do
            expect(instance.performed).to eq([])
          end

          instance.stub(:perform_each).with(:two, 2, 1) do
            expect(instance.performed).to eq([[:one, 1, 0]])
          end

          instance.stub(:perform_each).with(:three, 3, 2) do
            expect(instance.performed).to eq([[:one, 1, 0], [:two, 2, 1]])
          end

          expect {
            instance.perform
          }.to change {
            instance.performed
          }.from([]).to([[:one, 1, 0], [:two, 2, 1], [:three, 3, 2]])
        end

        it "aborts and rolls back on failure" do
          expect(instance).to receive(:perform_each).once.with(:one, 1, 0).ordered
          expect(instance).to receive(:perform_each).once.with(:two, 2, 1).ordered { instance.fail! }
          expect(instance).not_to receive(:perform_each).with(:three, 3, 2)

          expect(instance).to receive(:rollback).once.ordered do
            expect(instance.performed).to eq([[:one, 1, 0]])
          end

          instance.perform
        end

        context "with perform_each accepting two arguments" do
          before do
            instance.context[:args] = []

            iterator.class_eval do
              def perform_each(key, value)
                context[:args] << [key, value]
              end
            end
          end

          it "excludes the index from the arguments" do
            expect {
              instance.perform
            }.to change {
              instance.context[:args]
            }.from([]).to([[:one, 1], [:two, 2], [:three, 3]])
          end

          it "includes the index in the performed elements" do
            expect {
              instance.perform
            }.to change {
              instance.performed
            }.from([]).to([[:one, 1, 0], [:two, 2, 1], [:three, 3, 2]])
          end
        end
      end
    end

    describe "#rollback" do
      let(:instance) { iterator.new }

      context "with an array collection" do
        before do
          instance.stub(:performed) { [[1, 0], [2, 1]] }
        end

        it "rolls back each performed element in reverse" do
          expect(instance).to receive(:rollback_each).once.with(2, 1).ordered
          expect(instance).to receive(:rollback_each).once.with(1, 0).ordered

          instance.rollback
        end

        context "with rollback_each accepting one argument" do
          before do
            instance.context[:args] = []

            iterator.class_eval do
              def rollback_each(element)
                context[:args] << [element]
              end
            end
          end

          it "excludes the index from the arguments" do
            expect {
              instance.rollback
            }.to change {
              instance.context[:args]
            }.from([]).to([[2], [1]])
          end
        end
      end

      context "with a hash collection" do
        before do
          instance.stub(:performed) { [[:one, 1, 0], [:two, 2, 1]] }
        end

        it "rolls back each performed element in reverse" do
          expect(instance).to receive(:rollback_each).once.with(:two, 2, 1).ordered
          expect(instance).to receive(:rollback_each).once.with(:one, 1, 0).ordered

          instance.rollback
        end

        context "with rollback_each accepting two arguments" do
          before do
            instance.context[:args] = []

            iterator.class_eval do
              def rollback_each(key, value)
                context[:args] << [key, value]
              end
            end
          end

          it "excludes the index from the arguments" do
            expect {
              instance.rollback
            }.to change {
              instance.context[:args]
            }.from([]).to([[:two, 2], [:one, 1]])
          end
        end
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
