include Interactor::TestHelpers

module Interactor
  describe TestHelpers do
    let(:organizer)   { Class.new.send(:include, Organizer) }
    let(:interactor1) { Class.new.send(:include, Interactor) }
    let(:interactor2) { Class.new.send(:include, Interactor) }
    let(:interactor3) { Class.new.send(:include, Interactor) }

    before do
      organizer.organize([interactor1, interactor2, interactor3])
    end

    describe ".mock_organizer" do
      it "initializes a context for each interactor" do
        mock_organizer(organizer)

        expect(interactor1).to receive(:new)
        expect(interactor2).to receive(:new)
        expect(interactor3).to receive(:new)

        organizer.call
      end

      it "initializes a double, not a real context, for each interactor" do
        mock_organizer(organizer)

        expect(interactor1.new.context).to_not be_a(Context)
        expect(interactor2.new.context).to_not be_a(Context)
        expect(interactor3.new.context).to_not be_a(Context)

        organizer.call
      end
    end
  end
end
