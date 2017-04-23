require "ostruct"

module Interactor
  describe OrganizedInteractor do
    let(:interactor) { double(:interactor, call!: nil) }
    let(:organizer) { FakeOrganizer.new }
    let(:context) { double(:context) }

    class FakeOrganizer
      def context
        OpenStruct.new(truthy: true, falsey: false)
      end

      def truthy_method
        true
      end

      def falsey_method
        false
      end
    end

    def build_with_options_and_call(options)
      OrganizedInteractor.new(interactor, options).call!(context, organizer)
    end

    describe "#call!" do
      it "runs an interactor" do
        OrganizedInteractor.new(interactor).call!(context, organizer)
        expect(interactor).to have_received(:call!).with(context)
      end

      context "when :if option is a proc" do
        it "evaluates it within an organizer" do
          expect(organizer).to receive(:truthy_method).and_call_original
          build_with_options_and_call(if: -> { truthy_method })
        end

        it "runs an interactor if proc evaluation was truthy" do
          build_with_options_and_call(if: -> { context.truthy })
          expect(interactor).to have_received(:call!)
        end

        it "doesn't run an interactor if proc evaluation was falsey" do
          build_with_options_and_call(if: -> { context.falsey })
          expect(interactor).not_to have_received(:call!)
        end
      end

      context "when :unless option is a proc" do
        it "evaluates it within an organizer" do
          expect(organizer).to receive(:truthy_method).and_call_original
          build_with_options_and_call(unless: -> { truthy_method })
        end

        it "runs an interactor if proc evaluation was falsey" do
          build_with_options_and_call(unless: -> { context.falsey })
          expect(interactor).to have_received(:call!)
        end

        it "doesn't run an interactor if proc evaluation was truthy" do
          build_with_options_and_call(unless: -> { context.truthy })
          expect(interactor).not_to have_received(:call!)
        end
      end

      context "when :if option is a symbol" do
        it "treats it as organizer's method name" do
          expect(organizer).to receive(:truthy_method).and_call_original
          build_with_options_and_call(if: :truthy_method)
        end

        it "runs an interactor if method evaluation was truthy" do
          build_with_options_and_call(if: :truthy_method)
          expect(interactor).to have_received(:call!)
        end

        it "doesn't run an interactor if method evaluation was falsey" do
          build_with_options_and_call(if: :falsey_method)
          expect(interactor).not_to have_received(:call!)
        end
      end
    end
  end
end
