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
    end

    describe ".organized" do
      it "is empty by default" do
        expect(organizer.organized).to eq([])
      end
    end

    describe "#call" do
      let(:instance) { organizer.new }
      let(:context) { double(:context) }
      let(:interactor2) { double(:interactor2) }
      let(:interactor3) { double(:interactor3) }
      let(:interactor4) { double(:interactor4) }

      before do
        allow(instance).to receive(:context) { context }
        allow_any_instance_of(organizer).to receive(:true_method) { true }
        allow_any_instance_of(organizer).to receive(:false_method) { false }
      end

      it "calls each interactor in order with the context if no 'if' is passed" do
        allow(organizer).to receive(:organized) {
          [interactor2, interactor3, interactor4]
        }
        expect(interactor2).to receive(:call!).once.with(context).ordered
        expect(interactor3).to receive(:call!).once.with(context).ordered
        expect(interactor4).to receive(:call!).once.with(context).ordered

        instance.call
      end

      it "calls only interactors in order with if method that returns true, or without if method" do
        allow(organizer).to receive(:organized) {
          [{class: interactor2, if: :true_method}, {class: interactor3, if: :false_method}, interactor4]
        }
        expect(interactor2).to receive(:call!).once.with(context).ordered
        expect(interactor3).not_to receive(:call!)
        expect(interactor4).to receive(:call!).once.with(context).ordered

        instance.call
      end
    end
  end
end
