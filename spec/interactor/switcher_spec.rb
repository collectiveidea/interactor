module Interactor
  describe Switcher do
    include_examples :lint

    let(:switcher) { Class.new.send(:include, Switcher) }

    describe ".switch" do
      let(:interactor2) { double(:interactor2) }
      let(:interactor3) { double(:interactor3) }

      it "sets interactors given class arguments as seperate cases" do
        expect {
          switcher.switch(interactor2, interactor3)
        }.to change {
          switcher.cases
        }.from([]).to([interactor2, interactor3])
      end

      it "sets interactors given an array of classes as one case" do
        expect {
          switcher.switch([interactor2, interactor3])
        }.to change {
          switcher.cases
        }.from([]).to([[interactor2, interactor3]])
      end

      it "sets interactors given a hash of class arguments" do
        expect {
          switcher.switch({ path1: interactor2, path2: interactor3 })
        }.to change {
          switcher.cases
        }.from([]).to({ path1: interactor2, path2: interactor3 })
      end

      it "sets interactors given a hash that accepts values of arrays of class arguments" do
        expect {
          switcher.switch({ path1: [interactor2, interactor3], path2: interactor3 })
        }.to change {
          switcher.cases
        }.from([]).to({ path1: [interactor2, interactor3], path2: interactor3 })
      end

    end

    describe ".cases" do
      it "is empty by default" do
        expect(switcher.cases).to eq([])
      end
    end

    describe "#call" do
      let(:instance) { switcher.new }
      let(:context) { Interactor::Context.new }
      let(:interactor2) { double(:interactor2) }
      let(:interactor3) { double(:interactor3) }
      let(:interactor4) { double(:interactor4) }

      before do
        allow(instance).to receive(:context) { context }
      end

      it "calls the first case by default for flat arrays if switcher_condition is not specified" do
        allow(switcher).to receive(:cases) {
          [interactor2, interactor3, interactor4]
        }

        expect(interactor2).to receive(:call!).once.with(context)
        expect(interactor3).to_not receive(:call!).with(context)
        expect(interactor4).to_not receive(:call!).with(context)

        instance.call
      end

      it "calls the first case by default for nested arrays if switcher_condition is not specified" do
        allow(switcher).to receive(:cases) {
          [[interactor2, interactor3], interactor4]
        }

        expect(interactor2).to receive(:call!).once.with(context).ordered
        expect(interactor3).to receive(:call!).once.with(context).ordered
        expect(interactor4).to_not receive(:call!).with(context)

        instance.call
      end


      it "calls the first case by default for hashes if switcher_condition is not specified" do
        allow(switcher).to receive(:cases) {
          { case_1: [interactor2, interactor3], case_2: interactor4 }
        }

        expect(interactor2).to receive(:call!).once.with(context).ordered
        expect(interactor3).to receive(:call!).once.with(context).ordered
        expect(interactor4).to_not receive(:call!).with(context)

        instance.call
      end
    end

    describe "#call" do
      let(:instance) { switcher.new }
      let(:interactor2) { double(:interactor2) }
      let(:interactor3) { double(:interactor3) }
      let(:interactor4) { double(:interactor4) }

      it "calls the corresponding switcher_condition from cases of type Array" do
        context = Interactor::Context.new switcher_condition: 1

        allow(instance).to receive(:context) { context }
        allow(switcher).to receive(:cases) {
          [[interactor2, interactor3], interactor4]
        }

        expect(interactor2).to_not receive(:call!).with(context)
        expect(interactor3).to_not receive(:call!).with(context)
        expect(interactor4).to receive(:call!).once.with(context)

        instance.call
      end

      it "calls the corresponding switcher_condition from cases of type Hash" do
        context = Interactor::Context.new switcher_condition: :path_1

        allow(instance).to receive(:context) { context }
        allow(switcher).to receive(:cases) {
          { path_1: [interactor2, interactor3], path_2: interactor4 }
        }

        expect(interactor2).to receive(:call!).once.with(context).ordered
        expect(interactor3).to receive(:call!).once.with(context).ordered
        expect(interactor4).to_not receive(:call!).with(context)

        instance.call
      end

    end

  end
end
