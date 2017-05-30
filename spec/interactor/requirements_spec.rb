module Interactor
  describe Interactor do
    include_examples :lint

    class InteractorWithSimpleRequirements
      include Interactor
      context_requires :some_object
    end

    class InteractorWithTypedRequirements
      include Interactor
      context_requires some_string: String, some_hash: Hash
    end

    class InteractorWithMixedRequirements
      include Interactor
      context_requires :another_object, some_string: String
    end

    describe ".context_requires" do
      describe "with a simple requirement" do
        it "passes if the requirement exists" do
          expect{InteractorWithSimpleRequirements.call(some_object: 123)}.to_not raise_error
        end
        it "raises an error if it's missing a requirement" do
          expect{InteractorWithSimpleRequirements.call}.to raise_error(Interactor::RequirementsNotMet)
        end
        it "raises an error if it's a requirement is nil" do
          expect{InteractorWithSimpleRequirements.call(some_object: nil)}.to raise_error(Interactor::RequirementsNotMet)
        end
      end
      describe "with typed requirements" do
        it "raises an error if it's missing a requirement" do
          expect{InteractorWithTypedRequirements.call(some_string: nil)}.to raise_error(Interactor::RequirementsNotMet)        
        end
        it "raises an error if a requirement has the wrong type" do
          expect{InteractorWithTypedRequirements.call(some_string: 123)}.to raise_error(Interactor::RequirementsNotMet)        
        end
      end
      describe "with mixed requirements" do
        it "raises an error if it's missing a requirement" do
          expect{InteractorWithMixedRequirements.call(some_string: "abc")}.to raise_error(Interactor::RequirementsNotMet)        
        end
        it "raises an error if a requirement has the wrong type" do
          expect{InteractorWithMixedRequirements.call(some_string: 123)}.to raise_error(Interactor::RequirementsNotMet)        
        end
      end
    end
  end
end