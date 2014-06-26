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

    describe "#perform" do
      let(:instance) { organizer.new }
      let(:context) { instance.context }
      let(:interactor2) { double(:interactor2) }
      let(:interactor3) { double(:interactor3) }
      let(:interactor4) { double(:interactor4) }
      let(:instance2) { double(:instance2) }
      let(:instance3) { double(:instance3) }
      let(:instance4) { double(:instance4) }

      before do
        organizer.stub(:interactors) { [interactor2, interactor3, interactor4] }
      end

      it "performs each interactor in order with the context" do
        expect(interactor2).to receive(:perform).once.with(context).ordered { instance2 }
        expect(interactor3).to receive(:perform).once.with(context).ordered { instance3 }
        expect(interactor4).to receive(:perform).once.with(context).ordered { instance4 }

        expect(instance).not_to receive(:rollback)

        instance.perform
      end

      it "builds up the performed interactors" do
        interactor2.stub(:perform) do
          expect(instance.performed).to eq([])
          instance2
        end

        interactor3.stub(:perform) do
          expect(instance.performed).to eq([instance2])
          instance3
        end

        interactor4.stub(:perform) do
          expect(instance.performed).to eq([instance2, instance3])
          instance4
        end

        expect {
          instance.perform
        }.to change {
          instance.performed
        }.from([]).to([instance2, instance3, instance4])
      end

      it "aborts and rolls back on failure" do
        expect(interactor2).to receive(:perform).once.with(context).ordered { instance2 }
        expect(interactor3).to receive(:perform).once.with(context).ordered { context.fail! }
        expect(interactor4).not_to receive(:perform)

        expect(instance).to receive(:rollback).once.ordered do
          expect(instance.performed).to eq([instance2])
        end

        instance.perform
      end

      it "aborts and rolls back on error" do
        error = StandardError.new("foo")
        expect(interactor2).to receive(:perform).once.with(context).ordered { instance2 }
        expect(interactor3).to receive(:perform).once.with(context).ordered { raise error }
        expect(interactor4).not_to receive(:perform)

        expect(instance).to receive(:rollback).once.ordered do
          expect(instance.performed).to eq([instance2])
        end

        expect { instance.perform }.to raise_error(error)
      end

      it "aborts on halt" do
        expect(interactor2).to receive(:perform).once.with(context).ordered { instance2 }
        expect(interactor3).to receive(:perform).once.with(context).ordered { context.halt! }
        expect(interactor4).not_to receive(:perform)
        expect(instance).not_to receive(:rollback)

        instance.perform
      end
    end

    describe "#rollback" do
      let(:instance) { organizer.new }
      let(:instance2) { double(:instance2) }
      let(:instance3) { double(:instance3) }

      before do
        instance.stub(:performed) { [instance2, instance3] }
      end

      it "rolls back each performed interactor in reverse" do
        expect(instance3).to receive(:rollback).once.ordered
        expect(instance2).to receive(:rollback).once.ordered

        instance.rollback
      end
    end

    describe "#performed" do
      let(:instance) { organizer.new }

      it "is empty by default" do
        expect(instance.performed).to eq([])
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

      let(:instance2a) { double(:instance2a) }
      let(:instance2b) { double(:instance2b) }
      let(:instance2c) { double(:instance2c) }
      let(:instance3) { double(:instance3) }
      let(:instance4a) { double(:instance4a) }
      let(:instance4b) { double(:instance4b) }

      before do
        organizer.stub(:interactors) { [organizer2, interactor3, organizer4, interactor5] }
        organizer2.stub(:interactors) { [interactor2a, interactor2b, interactor2c] }
        organizer4.stub(:interactors) { [interactor4a, interactor4b, interactor4c] }
      end

      it "performs and rolls back properly" do
        expect(interactor2a).to receive(:perform).once.with(context).ordered { instance2a }
        expect(interactor2b).to receive(:perform).once.with(context).ordered { instance2b }
        expect(interactor2c).to receive(:perform).once.with(context).ordered { instance2c }
        expect(interactor3).to receive(:perform).once.with(context).ordered { instance3 }
        expect(interactor4a).to receive(:perform).once.with(context).ordered { instance4a }
        expect(interactor4b).to receive(:perform).once.with(context).ordered do
          context.fail!
          instance4b
        end
        expect(interactor4c).not_to receive(:perform)
        expect(interactor5).not_to receive(:perform)

        expect(instance4b).not_to receive(:rollback)
        expect(instance4a).to receive(:rollback).once.with(no_args).ordered
        expect(instance3).to receive(:rollback).once.with(no_args).ordered
        expect(instance2c).to receive(:rollback).once.with(no_args).ordered
        expect(instance2b).to receive(:rollback).once.with(no_args).ordered
        expect(instance2a).to receive(:rollback).once.with(no_args).ordered

        instance.perform
      end
    end
  end
end
