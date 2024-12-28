module Interactor
  describe ContextValidation do
    describe "when context keys are missing" do
      subject(:interactor) do
        module Test
          class SomeInteractor
            include Interactor
            include ContextValidation

            needs_context :a, :b

            def call
            end
          end
        end

        Test::SomeInteractor
      end

      it "raises an error" do
        expect { interactor.call({}) }.to raise_error(/Missing context: a, b/)
      end
    end

    context "when missing context keys are set in a before hook" do
      subject(:interactor) do
        module Test
          class InteractorWithContextInBeforeHook
            include Interactor
            include ContextValidation

            needs_context :a, :b

            before do
              context.a = 'a'
              context.b = 'b'
            end

            def call
            end
          end
        end

        Test::InteractorWithContextInBeforeHook
      end

      it "does not raise an error" do
        expect { interactor.call({}) }.not_to raise_error
      end
    end
  end
end
