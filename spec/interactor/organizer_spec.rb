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

      it "aborts and rolls back on failure" do
        expect(interactor2).to receive(:call).once.with(context).ordered
        expect(interactor3).to receive(:call).once.with(context).ordered do
          context.fail!
        end
        expect(interactor4).not_to receive(:call)

        expect(instance).to receive(:rollback_called).once.ordered do
          expect(instance.called).to eq([interactor2])
        end

        instance.call
      end

      it "aborts and rolls back on error" do
        error = StandardError.new("foo")
        expect(interactor2).to receive(:call).once.with(context).ordered
        expect(interactor3).to receive(:call).once.with(context).ordered do
          raise error
        end
        expect(interactor4).not_to receive(:call)

        expect(instance).to receive(:rollback_called).once.ordered do
          expect(instance.called).to eq([interactor2])
        end

        expect { instance.call }.to raise_error(error)
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

    # organizer
    #  ├─ organizer2
    #  │   ├─ interactor2a
    #  │   ├─ interactor2b
    #  │   └─ interactor2c
    #  ├─ interactor3
    #  ├─ organizer4
    #  │   ├─ interactor4a
    #  │   ├─ interactor4b
    #  │   └─ interactor4c
    #  └─ interactor5
    #
    context "organizers within organizers" do
      let(:instance) { organizer.new }
      let(:context) { instance.context }
      let(:organizer2) { Class.new.send(:include, Organizer) }
      let(:interactor2a) { double(:interactor2a) }
      let(:interactor2b) { double(:interactor2b) }
      let(:interactor2c) { double(:interactor2c) }
      let(:interactor3) { double(:interactor3) }
      let(:organizer4) { Class.new.send(:include, Organizer) }
      let(:interactor4a) { double(:interactor4a) }
      let(:interactor4b) { double(:interactor4b) }
      let(:interactor4c) { double(:interactor4c) }
      let(:interactor5) { double(:interactor5) }

      before do
        organizer.stub(:interactors) { [organizer2, interactor3, organizer4, interactor5] }
        organizer2.stub(:interactors) { [interactor2a, interactor2b, interactor2c] }
        organizer4.stub(:interactors) { [interactor4a, interactor4b, interactor4c] }
      end

      it "calls and rolls back properly" do
        expect(interactor2a).to receive(:call).once.with(context).ordered
        expect(interactor2b).to receive(:call).once.with(context).ordered
        expect(interactor2c).to receive(:call).once.with(context).ordered
        expect(interactor3).to receive(:call).once.with(context).ordered
        expect(interactor4a).to receive(:call).once.with(context).ordered
        expect(interactor4b).to receive(:call).once.with(context).ordered do
          context.fail!
        end
        expect(interactor4c).not_to receive(:call)
        expect(interactor5).not_to receive(:call)

        expect(interactor5).not_to receive(:rollback)
        expect(interactor4c).not_to receive(:rollback)
        expect(interactor4b).not_to receive(:rollback)
        expect(interactor4a).to receive(:rollback).once.with(context).ordered
        expect(interactor3).to receive(:rollback).once.with(context).ordered
        expect(interactor2c).to receive(:rollback).once.with(context).ordered
        expect(interactor2b).to receive(:rollback).once.with(context).ordered
        expect(interactor2a).to receive(:rollback).once.with(context).ordered

        instance.call
      end
    end
  end
end
