describe Interactor do
  include_examples :lint

  describe "#call" do
    let(:interactor) { Class.new.send(:include, described_class) }

    context "positional arguments" do
      it "accepts required positional arguments" do
        interactor.class_eval do
          def call(foo)
            context.output = foo
          end
        end

        result = interactor.call(foo: "baz", hello: "world")

        expect(result.output).to eq("baz")
      end

      it "accepts optional positional arguments" do
        interactor.class_eval do
          def call(foo = "bar")
            context.output = foo
          end
        end

        result = interactor.call(foo: "baz", hello: "world")

        expect(result.output).to eq("baz")
      end

      it "assigns absent positional arguments" do
        interactor.class_eval do
          def call(foo = "bar")
            context.output = foo
          end
        end

        result = interactor.call(hello: "world")

        expect(result.output).to eq("bar")
      end

      it "raises an error for missing positional arguments" do
        interactor.class_eval do
          def call(foo)
            context.output = foo
          end
        end

        expect { interactor.call(hello: "world") }.to raise_error(ArgumentError)
      end
    end

    context "keyword arguments" do
      it "accepts required keyword arguments" do
        interactor.class_eval do
          def call(foo:)
            context.output = foo
          end
        end

        result = interactor.call(foo: "baz", hello: "world")

        expect(result.output).to eq("baz")
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
    end

    context "combination arguments" do
      it "accepts required positional with required keyword arguments" do
        interactor.class_eval do
          def call(foo, hello:)
            context.output = [foo, hello]
          end
        end

        result = interactor.call(foo: "baz", hello: "world")

        expect(result.output).to eq(["baz", "world"])
      end

      it "accepts required positional with optional keyword arguments" do
        interactor.class_eval do
          def call(foo, hello: "there")
            context.output = [foo, hello]
          end
        end

        result = interactor.call(foo: "baz", hello: "world")

        expect(result.output).to eq(["baz", "world"])
      end

      it "accepts required positional and assigns absent keyword arguments" do
        interactor.class_eval do
          def call(foo, hello: "there")
            context.output = [foo, hello]
          end
        end

        result = interactor.call(foo: "baz")

        expect(result.output).to eq(["baz", "there"])
      end

      it "accepts optional positional with required keyword arguments" do
        interactor.class_eval do
          def call(foo = "bar", hello:)
            context.output = [foo, hello]
          end
        end

        result = interactor.call(foo: "baz", hello: "world")

        expect(result.output).to eq(["baz", "world"])
      end

      it "accepts optional positional with optional keyword arguments" do
        interactor.class_eval do
          def call(foo = "bar", hello: "there")
            context.output = [foo, hello]
          end
        end

        result = interactor.call(foo: "baz", hello: "world")

        expect(result.output).to eq(["baz", "world"])
      end

      it "accepts optional positional and assigns absent keyword arguments" do
        interactor.class_eval do
          def call(foo = "bar", hello: "there")
            context.output = [foo, hello]
          end
        end

        result = interactor.call(foo: "baz")

        expect(result.output).to eq(["baz", "there"])
      end

      it "assigns absent positional and accepts required keyword arguments" do
        interactor.class_eval do
          def call(foo = "bar", hello:)
            context.output = [foo, hello]
          end
        end

        result = interactor.call(hello: "world")

        expect(result.output).to eq(["bar", "world"])
      end

      it "assigns absent positional and accepts optional keyword arguments" do
        interactor.class_eval do
          def call(foo = "bar", hello: "there")
            context.output = [foo, hello]
          end
        end

        result = interactor.call(hello: "world")

        expect(result.output).to eq(["bar", "world"])
      end

      it "assigns absent positional and absent keyword arguments" do
        interactor.class_eval do
          def call(foo = "bar", hello: "there")
            context.output = [foo, hello]
          end
        end

        result = interactor.call

        expect(result.output).to eq(["bar", "there"])
      end
    end
  end
end
