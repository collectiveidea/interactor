module Interactor
  describe Hooks do
    describe "#with_hooks" do
      def build_hooked(&block) # rubocop:disable Metrics/MethodLength
        hooked = Class.new.send(:include, Interactor::Hooks)

        hooked.class_eval do
          attr_reader :steps

          def self.process
            new.tap(&:process).steps
          end

          def initialize
            @steps = []
          end

          def process
            with_hooks { steps << :process }
          end
        end

        hooked.class_eval(&block) if block
        hooked
      end

      context "with an around hook method" do
        let(:hooked) {
          build_hooked do
            around :add_around_before_and_around_after

            private

            def add_around_before_and_around_after(hooked)
              steps << :around_before
              hooked.call
              steps << :around_after
            end
          end
        }

        it "runs the around hook method" do
          expect(hooked.process).to eq([
            :around_before,
            :process,
            :around_after,
          ])
        end
      end

      context "with an around hook block" do
        let(:hooked) {
          build_hooked do
            around do |hooked|
              steps << :around_before
              hooked.call
              steps << :around_after
            end
          end
        }

        it "runs the around hook block" do
          expect(hooked.process).to eq([
            :around_before,
            :process,
            :around_after,
          ])
        end
      end

      context "with an around hook method and block in one call" do
        let(:hooked) {
          build_hooked do
            around :add_around_before1_and_around_after1 do |hooked|
              steps << :around_before2
              hooked.call
              steps << :around_after2
            end

            private

            def add_around_before1_and_around_after1(hooked)
              steps << :around_before1
              hooked.call
              steps << :around_after1
            end
          end
        }

        it "runs the around hook method and block in order" do
          expect(hooked.process).to eq([
            :around_before1,
            :around_before2,
            :process,
            :around_after2,
            :around_after1,
          ])
        end
      end

      context "with an around hook method and block in multiple calls" do
        let(:hooked) {
          build_hooked do
            around do |hooked|
              steps << :around_before1
              hooked.call
              steps << :around_after1
            end

            around :add_around_before2_and_around_after2

            private

            def add_around_before2_and_around_after2(hooked)
              steps << :around_before2
              hooked.call
              steps << :around_after2
            end
          end
        }

        it "runs the around hook block and method in order" do
          expect(hooked.process).to eq([
            :around_before1,
            :around_before2,
            :process,
            :around_after2,
            :around_after1,
          ])
        end
      end

      context "with a before hook method" do
        let(:hooked) {
          build_hooked do
            before :add_before

            private

            def add_before
              steps << :before
            end
          end
        }

        it "runs the before hook method" do
          expect(hooked.process).to eq([
            :before,
            :process,
          ])
        end
      end

      context "with a before hook block" do
        let(:hooked) {
          build_hooked do
            before do
              steps << :before
            end
          end
        }

        it "runs the before hook block" do
          expect(hooked.process).to eq([
            :before,
            :process,
          ])
        end
      end

      context "with a before hook method and block in one call" do
        let(:hooked) {
          build_hooked do
            before :add_before1 do
              steps << :before2
            end

            private

            def add_before1
              steps << :before1
            end
          end
        }

        it "runs the before hook method and block in order" do
          expect(hooked.process).to eq([
            :before1,
            :before2,
            :process,
          ])
        end
      end

      context "with a before hook method and block in multiple calls" do
        let(:hooked) {
          build_hooked do
            before do
              steps << :before1
            end

            before :add_before2

            private

            def add_before2
              steps << :before2
            end
          end
        }

        it "runs the before hook block and method in order" do
          expect(hooked.process).to eq([
            :before1,
            :before2,
            :process,
          ])
        end
      end

      context "with an after hook method" do
        let(:hooked) {
          build_hooked do
            after :add_after

            private

            def add_after
              steps << :after
            end
          end
        }

        it "runs the after hook method" do
          expect(hooked.process).to eq([
            :process,
            :after,
          ])
        end
      end

      context "with an after hook block" do
        let(:hooked) {
          build_hooked do
            after do
              steps << :after
            end
          end
        }

        it "runs the after hook block" do
          expect(hooked.process).to eq([
            :process,
            :after,
          ])
        end
      end

      context "with an after hook method and block in one call" do
        let(:hooked) {
          build_hooked do
            after :add_after1 do
              steps << :after2
            end

            private

            def add_after1
              steps << :after1
            end
          end
        }

        it "runs the after hook method and block in order" do
          expect(hooked.process).to eq([
            :process,
            :after2,
            :after1,
          ])
        end
      end

      context "with an after hook method and block in multiple calls" do
        let(:hooked) {
          build_hooked do
            after do
              steps << :after1
            end

            after :add_after2

            private

            def add_after2
              steps << :after2
            end
          end
        }

        it "runs the after hook block and method in order" do
          expect(hooked.process).to eq([
            :process,
            :after2,
            :after1,
          ])
        end
      end

      context "with around, before and after hooks" do
        let(:hooked) {
          build_hooked do
            around do |hooked|
              steps << :around_before1
              hooked.call
              steps << :around_after1
            end

            around do |hooked|
              steps << :around_before2
              hooked.call
              steps << :around_after2
            end

            before do
              steps << :before1
            end

            before do
              steps << :before2
            end

            after do
              steps << :after1
            end

            after do
              steps << :after2
            end
          end
        }

        it "runs hooks in the proper order" do
          expect(hooked.process).to eq([
            :around_before1,
            :around_before2,
            :before1,
            :before2,
            :process,
            :after2,
            :after1,
            :around_after2,
            :around_after1,
          ])
        end
      end
    end
  end
end
