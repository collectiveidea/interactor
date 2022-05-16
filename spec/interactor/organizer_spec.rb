module Interactor
  describe Organizer do
    include_examples :lint

    let(:organizer) { Class.new.send(:include, Organizer) }

    let(:interactor2) { double(:interactor2) }
    let(:interactor3) { double(:interactor3) }
    let(:interactor4) { double(:interactor4) }

    describe ".organize" do
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

      before do
        allow(instance).to receive(:context) { context }
        allow(organizer).to receive(:organized) {
          [interactor2, interactor3, interactor4]
        }
      end

      it "calls each interactor in order with the context" do
        expect(interactor2).to receive(:call!).once.with(context).ordered
        expect(interactor3).to receive(:call!).once.with(context).ordered
        expect(interactor4).to receive(:call!).once.with(context).ordered

        instance.call
      end
    end

    describe ".ensure_do" do
      it "sets interactors given class arguments" do
        expect {
          organizer.ensure_do(interactor2, interactor3)
        }.to change {
          organizer.ensured
        }.from([]).to([interactor2, interactor3])
      end

      it "sets interactors given an array of classes" do
        expect {
          organizer.ensure_do([interactor2, interactor3])
        }.to change {
          organizer.ensured
        }.from([]).to([interactor2, interactor3])
      end
    end

    describe ".ensured" do
      it "is empty by default" do
        expect(organizer.ensured).to eq([])
      end
    end

    describe "#call" do
      let(:instance) { organizer.new }
      let(:context) { double(:context) }
      let(:interactor5) { double(:interactor2) }

      before do
        allow(instance).to receive(:context) { context }
        allow(organizer).to receive(:organized) {
          [interactor2, interactor3, interactor4]
        }
        allow(organizer).to receive(:ensured) {
          [interactor5]
        }
      end

      it "calls each interactor in order with the context" do
        expect(interactor2).to receive(:call!).once.with(context).ordered
        expect(interactor3).to receive(:call!).once.with(context).ordered
        expect(interactor4).to receive(:call!).once.with(context).ordered
        expect(interactor5).to receive(:call).once.with(context).ordered

        instance.call
      end

      it "calls the ensure interactor when there is an error in one organized interactor" do
        expect(interactor2).to receive(:call!).and_raise(Failure)
        expect(interactor5).to receive(:call).once.with(context)

        expect { instance.call }.to raise_error(Failure)
      end
    end
  end
end
