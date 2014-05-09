require "spec_helper"

module Interactor
  describe Organizer do
    include_examples :lint

    let(:organizer) { Class.new.send(:include, Organizer) }

    describe ".interactors" do
      it "is empty by default" do
        expect(organizer.interactors).to eq([])
      end
    end

    describe ".organize" do
      let(:interactor2) { double(:interactor2) }
      let(:interactor3) { double(:interactor3) }

      it "sets interactors given class arguments" do
        expect {
          organizer.organize(interactor2, interactor3)
        }.to change {
          organizer.interactors
        }.from([]).to([interactor2, interactor3])
      end

      it "sets interactors given an array of classes" do
        expect {
          organizer.organize([interactor2, interactor3])
        }.to change {
          organizer.interactors
        }.from([]).to([interactor2, interactor3])
      end
    end

    describe "#interactors" do
      let(:interactors) { double(:interactors) }
      let(:instance) { organizer.new }

      before do
        organizer.stub(:interactors) { interactors }
      end

      it "defers to the class" do
        expect(instance.interactors).to eq(interactors)
      end
    end

    describe "#call" do
      let(:instance) { organizer.new }
      let(:context) { instance.context }
      let(:interactor2) { double(:interactor2) }
      let(:interactor3) { double(:interactor3) }
      let(:interactor4) { double(:interactor4) }

      before do
        organizer.stub(:interactors) { [interactor2, interactor3, interactor4] }
      end

      it "calls each interactor in order with the context" do
        expect(interactor2).to receive(:call).once.with(context).ordered
        expect(interactor3).to receive(:call).once.with(context).ordered
        expect(interactor4).to receive(:call).once.with(context).ordered

        expect(instance).not_to receive(:rollback)

        instance.call
      end

      it "builds up the called interactors" do
        interactor2.stub(:call) do
          expect(instance.called).to eq([])
          interactor2
        end

        interactor3.stub(:call) do
          expect(instance.called).to eq([interactor2])
          interactor3
        end

        interactor4.stub(:call) do
          expect(instance.called).to eq([interactor2, interactor3])
          interactor4
        end

        expect {
          instance.call
        }.to change {
          instance.called
        }.from([]).to([interactor2, interactor3, interactor4])
      end

      context "when an interactor fails" do
        before do
          interactor2.stub(:call) { context.fail! }
        end

        it "aborts" do
          expect(interactor4).not_to receive(:call)

          instance.call rescue nil
        end

        it "rolls back" do
          expect(instance).to receive(:rollback_called).once do
            expect(instance.called).to eq([interactor2])
          end

          instance.call rescue nil
        end

        it "raises failure" do
          expect {
            instance.call
          }.to raise_error(Failure)
        end
      end

      context "when an interactor errors" do
        before do
          interactor2.stub(:call) { raise "foo" }
        end

        it "aborts" do
          expect(interactor4).not_to receive(:call)

          instance.call rescue nil
        end

        it "rolls back" do
          expect(instance).to receive(:rollback_called).once do
            expect(instance.called).to eq([interactor2])
          end

          instance.call rescue nil
        end

        it "raises the error" do
          expect {
            instance.call
          }.to raise_error("foo")
        end
      end
    end

    describe "#rollback" do
      let(:instance) { organizer.new }
      let(:interactor2) { double(:interactor2) }
      let(:interactor3) { double(:interactor3) }

      before do
        instance.stub(:interactors) { [interactor2, interactor3] }
      end

      it "rolls back each organized interactor in reverse" do
        expect(interactor3).to receive(:rollback).once.ordered
        expect(interactor2).to receive(:rollback).once.ordered

        instance.rollback
      end
    end

    describe "#rollback_called" do
      let(:instance) { organizer.new }
      let(:interactor2) { double(:interactor2) }
      let(:interactor3) { double(:interactor3) }

      before do
        instance.stub(:called) { [interactor2, interactor3] }
      end

      it "rolls back each called interactor in reverse" do
        expect(interactor3).to receive(:rollback).once.ordered
        expect(interactor2).to receive(:rollback).once.ordered

        instance.rollback_called
      end
    end

    describe "#called" do
      let(:instance) { organizer.new }

      it "is empty by default" do
        expect(instance.called).to eq([])
      end
    end
  end
end
