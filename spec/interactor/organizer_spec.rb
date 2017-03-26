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
          organizer.organized
        }.from([]).to([interactor2, interactor3])
      end

      it "sets interactors given an array of classes" do
        expect {
          organizer.organize([interactor2, interactor3])
        }.to change {
          organizer.organized
        }.from([]).to([interactor2, interactor3])
      end

      it "allows multiple organize calls" do
        interactor4 = double(:interactor4)
        expect {
          organizer.organize(interactor2, interactor3)
          organizer.organize(interactor4)
        }.to change {
          organizer.organized
        }.from([]).to([interactor2, interactor3, interactor4])
      end
    end

    describe ".organized" do
      it "is empty by default" do
        expect(organizer.organized).to eq([])
      end
    end

    describe "#call" do
      let(:instance) { organizer.new }
      let(:context) { double(:context, failure?: false) }
      let(:interactor2) { double(:interactor2) }
      let(:interactor3) { double(:interactor3) }
      let(:interactor4) { double(:interactor4) }
      let(:organized_interactors) { [interactor2, interactor3, interactor4] }

      before do
        allow(instance).to receive(:context) { context }
        allow(organizer).to receive(:organized) { organized_interactors }
        organized_interactors.each do |organized_interactor|
          allow(organized_interactor).to receive(:call)
        end
      end

      it "calls each interactor in order with the context" do
        expect(interactor2).to receive(:call).once.with(context).ordered
        expect(interactor3).to receive(:call).once.with(context).ordered
        expect(interactor4).to receive(:call).once.with(context).ordered

        instance.call
      end

      it "signals about early_return on failure of one of organizers" do
        allow(context).to receive(:failure?).and_return(false, true)
        expect(context).to receive(:signal_early_return!).and_throw(:foo)
        expect {
          instance.call
        }.to throw_symbol
      end
    end
  end
end
