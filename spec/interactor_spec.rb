describe Interactor do
  include_examples :lint

  describe "#call" do
    let(:interactor) { Class.new.send(:include, described_class) }

    context "keyword arguments" do
      it "accepts required keyword arguments" do
        interactor.class_eval do
          def call(foo:)
            context.output = foo
          end
        end

        result = interactor.call(foo: "bar", hello: "world")

        expect(result.output).to eq("bar")
      end

      it "accepts optional keyword arguments" do
        interactor.class_eval do
          def call(foo: "bar")
            context.output = foo
          end
        end

        result = interactor.call(foo: "baz", hello: "world")

        expect(result.output).to eq("baz")
      end

      it "assigns absent keyword arguments" do
        interactor.class_eval do
          def call(foo: "bar")
            context.output = foo
          end
        end

        result = interactor.call(hello: "world")

        expect(result.output).to eq("bar")
      end

      it "raises an error for missing keyword arguments" do
        interactor.class_eval do
          def call(foo:)
            context.output = foo
          end
        end

        expect { interactor.call(hello: "world") }.to raise_error(ArgumentError)
      end

      it "raises an error for call definitions with non-keyword arguments" do
        interactor.class_eval do
          def call(foo)
            context.output = foo
          end
        end

        expect { interactor.call(foo: "bar") }.to raise_error(ArgumentError)
      end
    end
  end
end
