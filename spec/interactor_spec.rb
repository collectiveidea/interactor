describe Interactor do
  include_examples :lint
end

describe "Interactor()" do
  it "builds a class that includes Interactor" do
    interactor = Interactor{ }

    expect(interactor).to be_a(Class)
    expect(interactor).to include(Interactor)
  end

  it "defines the new class perform method using the given block" do
    interactor = Interactor{ context[:check] = true }
    result = interactor.perform

    expect(result.check).to be_true
  end
end
