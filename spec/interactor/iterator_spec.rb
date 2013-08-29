require "spec_helper"

module Interactor
  describe Iterator do
    include_examples :lint

    let(:iterator) { Class.new.send(:include, Iterator) }

    describe ".collect" do
      it "sets the collection key" do
        expect {
          iterator.collect(:elements)
        }.to change {
          iterator.collection_key
        }.from(nil).to(:elements)
      end
    end

    describe ".collection_key" do
      it "is nil by default" do
        expect(iterator.collection_key).to be_nil
      end
    end

    describe "#perform" do
      context "with an array collection" do
        let(:instance) { iterator.new(elements: [1, 2, 3]) }

        before do
          iterator.stub(collection_key: :elements)
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
            expect(instance.send(:_performed)).to eq([])
          end

          instance.stub(:perform_each).with(2, 1) do
            expect(instance.send(:_performed)).to eq([[1, 0]])
          end

          instance.stub(:perform_each).with(3, 2) do
            expect(instance.send(:_performed)).to eq([[1, 0], [2, 1]])
          end

          expect {
            instance.perform
          }.to change {
            instance.send(:_performed)
          }.from([]).to([[1, 0], [2, 1], [3, 2]])
        end

        it "aborts and rolls back on failure" do
          expect(instance).to receive(:perform_each).once.with(1, 0).ordered
          expect(instance).to receive(:perform_each).once.with(2, 1).ordered { instance.fail! }
          expect(instance).not_to receive(:perform_each).with(3, 2)

          expect(instance).to receive(:rollback).once.ordered do
            expect(instance.send(:_performed)).to eq([[1, 0]])
          end

          instance.perform
        end

        it "skips all elements if failed prior to performance" do
          instance.fail!

          expect(instance).not_to receive(:perform_each).with(1, 0)
          expect(instance).not_to receive(:perform_each).with(2, 1)
          expect(instance).not_to receive(:perform_each).with(3, 2)

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
              instance.send(:_performed)
            }.from([]).to([[1, 0], [2, 1], [3, 2]])
          end
        end
      end

      context "with a hash collection" do
        let(:instance) { iterator.new(pairs: {one: 1, two: 2, three: 3}) }

        before do
          iterator.stub(collection_key: :pairs)
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
            expect(instance.send(:_performed)).to eq([])
          end

          instance.stub(:perform_each).with(:two, 2, 1) do
            expect(instance.send(:_performed)).to eq([[:one, 1, 0]])
          end

          instance.stub(:perform_each).with(:three, 3, 2) do
            expect(instance.send(:_performed)).to eq([[:one, 1, 0], [:two, 2, 1]])
          end

          expect {
            instance.perform
          }.to change {
            instance.send(:_performed)
          }.from([]).to([[:one, 1, 0], [:two, 2, 1], [:three, 3, 2]])
        end

        it "aborts and rolls back on failure" do
          expect(instance).to receive(:perform_each).once.with(:one, 1, 0).ordered
          expect(instance).to receive(:perform_each).once.with(:two, 2, 1).ordered { instance.fail! }
          expect(instance).not_to receive(:perform_each).with(:three, 3, 2)

          expect(instance).to receive(:rollback).once.ordered do
            expect(instance.send(:_performed)).to eq([[:one, 1, 0]])
          end

          instance.perform
        end

        it "skips all key/value pairs if failed prior to performance" do
          instance.fail!

          expect(instance).not_to receive(:perform_each).with(:one, 1, 0)
          expect(instance).not_to receive(:perform_each).with(:two, 2, 1)
          expect(instance).not_to receive(:perform_each).with(:three, 3, 2)

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
              instance.send(:_performed)
            }.from([]).to([[:one, 1, 0], [:two, 2, 1], [:three, 3, 2]])
          end
        end
      end
    end

    describe "#rollback" do
      let(:instance) { iterator.new }

      context "with an array collection" do
        before do
          instance.stub(:_performed) { [[1, 0], [2, 1]] }
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
          instance.stub(:_performed) { [[:one, 1, 0], [:two, 2, 1]] }
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

    describe "#missing_collection!" do
      let(:instance) { iterator.new }

      it "raises an error by default" do
        expect {
          instance.missing_collection!
        }.to raise_error(Iterator::MissingCollection)
      end
    end

    describe "#_collection" do
      let(:instance) { iterator.new(elements: [1, 2, 3], element: 4, foo: nil) }

      it "reacts to a missing collection key" do
        expect(instance).to receive(:missing_collection!).once { [5, 6, 7] }

        expect(instance.send(:_collection)).to eq([5, 6, 7])
      end

      it "reacts to a missing collection" do
        expect(instance).to receive(:missing_collection!).once { [5, 6, 7] }

        expect(instance.send(:_collection)).to eq([5, 6, 7])
      end

      it "returns the collection from the context" do
        iterator.stub(collection_key: :elements)

        expect(instance.send(:_collection)).to eq([1, 2, 3])
      end

      it "wraps single elements in an array" do
        iterator.stub(collection_key: :element)

        expect(instance.send(:_collection)).to eq([4])
      end

      it "converts nil into an empty array" do
        iterator.stub(collection_key: :foo)

        expect(instance.send(:_collection)).to eq([])
      end
    end

    describe "#_performed" do
      let(:instance) { iterator.new }

      it "is empty by default" do
        expect(instance.send(:_performed)).to eq([])
      end
    end
  end
end
