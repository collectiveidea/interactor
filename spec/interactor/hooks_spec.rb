module Interactor
  describe Hooks do
    describe "#with_hooks" do
      def build_hooked(&block)
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
            :around_after
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
            :around_after
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
            :around_after1
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
            :around_after1
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
            :process
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
            :process
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
            :process
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
            :process
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
            :after
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
            :after
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
            :after1
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
            :after1
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
            :around_after1
          ])
        end
      end

      context "with inheritance" do
        context "with multiple ancestors" do
          let(:ancestor_top) {
            build_hooked do
              around do |interactor|
                steps << :around_before_ancestor_top
                interactor.call
                steps << :around_after_ancestor_top
              end

              before do
                steps << :before_ancestor_top
              end

              after do
                steps << :after_ancestor_top
              end
            end
          }

          let(:ancestor) {
            Class.new(ancestor_top) do
              around do |interactor|
                steps << :around_before_ancestor
                interactor.call
                steps << :around_after_ancestor
              end

              before do
                steps << :before_ancestor
              end

              after do
                steps << :after_ancestor
              end
            end
          }

          let(:hooked) {
            Class.new(ancestor) do
              around do |interactor|
                steps << :around_before
                interactor.call
                steps << :around_after
              end

              before do
                steps << :before
              end

              after do
                steps << :after
              end
            end
          }

          it "runs hooks defined in ancestors" do
            expect(hooked.process).to eq([
              :around_before,
              :around_before_ancestor,
              :around_before_ancestor_top,
              :before,
              :before_ancestor,
              :before_ancestor_top,
              :process,
              :after_ancestor_top,
              :after_ancestor,
              :after,
              :around_after_ancestor_top,
              :around_after_ancestor,
              :around_after
            ])
          end
        end

        describe "with hooks added to ancestors at runtime" do
          let(:ancestor) {
            build_hooked do
              before do
                steps << :before_at_parse
              end
            end
          }

          let(:hooked) {
            Class.new(ancestor)
          }

          before do
            ancestor.before do
              steps << :before_at_runtime
            end
          end

          it "runs hooks defined in ancestors" do
            expect(hooked.process).to eq([
              :before_at_parse,
              :before_at_runtime,
              :process
            ])
          end
        end
      end
    end
  end
end
