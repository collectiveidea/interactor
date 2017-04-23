module Interactor
  describe Organizer do
    include_examples :lint

    let(:organizer) { Class.new.send(:include, Organizer) }

    describe ".organize" do
      let(:interactor2) { double(:interactor2) }
      let(:interactor3) { double(:interactor3) }

      it "sets interactors given class arguments" do
        expect {
          organizer.organize(interactor2, interactor3)
        }.to change {
          organizer.organized.map(&:interactor)
        }.from([]).to([interactor2, interactor3])
      end

      it "sets interactors given an array of classes" do
        expect {
          organizer.organize([interactor2, interactor3])
        }.to change {
          organizer.organized.map(&:interactor)
        }.from([]).to([interactor2, interactor3])
      end

      it "allows multiple organize calls" do
        interactor4 = double(:interactor4)
        expect {
          organizer.organize(interactor2, interactor3)
          organizer.organize(interactor4)
        }.to change {
          organizer.organized.map(&:interactor)
        }.from([]).to([interactor2, interactor3, interactor4])
      end

      it "passes options to organized interactors" do
        expect(OrganizedInteractor).to receive(:new).with(interactor2, if: :foo)
        organizer.organize(interactor2, if: :foo)
      end

      it "duplicates and freezes original options hash" do
        original_options = { if: :foo }
        expect(OrganizedInteractor).to receive(:new) do |_, passed_options|
          expect(passed_options).not_to be(original_options)
          expect(passed_options).to be_frozen
        end
        organizer.organize(interactor2, original_options)
      end
    end

    describe ".organized" do
      it "is empty by default" do
        expect(organizer.organized).to eq([])
      end

      it "returns an array of OrganizedInteractors" do
        organizer.organize(double(:interactor))
        expect(organizer.organized).to all(be_an(OrganizedInteractor))
      end
    end

    describe "#call" do
      let(:instance) { organizer.new }
      let(:context) { double(:context) }
      let(:organized_interactor2) { double(:organized_interactor2) }
      let(:organized_interactor3) { double(:organized_interactor3) }

      it "calls each organized interactor in order with the context" do
        allow(instance).to receive(:context) { context }
        allow(organizer).to receive(:organized).and_return(
          [organized_interactor2, organized_interactor3]
        )

        expect(organized_interactor2)
          .to receive(:call!).with(context, instance).ordered
        expect(organized_interactor3)
          .to receive(:call!).with(context, instance).ordered

        instance.call
      end
    end
  end
end
