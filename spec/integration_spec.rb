require "spec_helper"

describe "Integration" do
  def build_interactor(&block)
    interactor = Class.new.send(:include, Interactor)
    interactor.class_eval(&block) if block
    interactor
  end

  def build_organizer(options = {}, &block)
    organizer = Class.new.send(:include, Interactor::Organizer)
    organizer.organize(options[:organize]) if options[:organize]
    organizer.class_eval(&block) if block
    organizer
  end

  # organizer
  #  ├─ organizer2
  #  │   ├─ interactor2a
  #  │   ├─ interactor2b
  #  │   └─ interactor2c
  #  ├─ interactor3
  #  ├─ organizer4
  #  │   ├─ interactor4a
  #  │   ├─ interactor4b
  #  │   └─ interactor4c
  #  └─ interactor5

  let(:organizer) {
    build_organizer(organize: [organizer2, interactor3, organizer4, interactor5]) do
      before do
        context.steps << :before
      end

      after do
        context.steps << :after
      end
    end
  }

  let(:organizer2) {
    build_organizer(organize: [interactor2a, interactor2b, interactor2c]) do
      before do
        context.steps << :before2
      end

      after do
        context.steps << :after2
      end
    end
  }

  let(:interactor2a) {
    build_interactor do
      before do
        context.steps << :before2a
      end

      after do
        context.steps << :after2a
      end

      def call
        context.steps << :call2a
      end

      def rollback
        context.steps << :rollback2a
      end
    end
  }

  let(:interactor2b) {
    build_interactor do
      before do
        context.steps << :before2b
      end

      after do
        context.steps << :after2b
      end

      def call
        context.steps << :call2b
      end

      def rollback
        context.steps << :rollback2b
      end
    end
  }

  let(:interactor2c) {
    build_interactor do
      before do
        context.steps << :before2c
      end

      after do
        context.steps << :after2c
      end

      def call
        context.steps << :call2c
      end

      def rollback
        context.steps << :rollback2c
      end
    end
  }

  let(:interactor3) {
    build_interactor do
      before do
        context.steps << :before3
      end

      after do
        context.steps << :after3
      end

      def call
        context.steps << :call3
      end

      def rollback
        context.steps << :rollback3
      end
    end
  }

  let(:organizer4) {
    build_organizer(organize: [interactor4a, interactor4b, interactor4c]) do
      before do
        context.steps << :before4
      end

      after do
        context.steps << :after4
      end
    end
  }

  let(:interactor4a) {
    build_interactor do
      before do
        context.steps << :before4a
      end

      after do
        context.steps << :after4a
      end

      def call
        context.steps << :call4a
      end

      def rollback
        context.steps << :rollback4a
      end
    end
  }

  let(:interactor4b) {
    build_interactor do
      before do
        context.steps << :before4b
      end

      after do
        context.steps << :after4b
      end

      def call
        context.steps << :call4b
      end

      def rollback
        context.steps << :rollback4b
      end
    end
  }

  let(:interactor4c) {
    build_interactor do
      before do
        context.steps << :before4c
      end

      after do
        context.steps << :after4c
      end

      def call
        context.steps << :call4c
      end

      def rollback
        context.steps << :rollback4c
      end
    end
  }

  let(:interactor5) {
    build_interactor do
      before do
        context.steps << :before5
      end

      after do
        context.steps << :after5
      end

      def call
        context.steps << :call5
      end

      def rollback
        context.steps << :rollback5
      end
    end
  }

  let(:context) { Interactor::Context.build(steps: []) }

  context "when successful" do
    it "calls and runs hooks in the proper sequence" do
      expect {
        organizer.call(context)
      }.to change {
        context.steps
      }.from([]).to([
        :before,
          :before2,
            :before2a, :call2a, :after2a,
            :before2b, :call2b, :after2b,
            :before2c, :call2c, :after2c,
          :after2,
          :before3, :call3, :after3,
          :before4,
            :before4a, :call4a, :after4a,
            :before4b, :call4b, :after4b,
            :before4c, :call4c, :after4c,
          :after4,
          :before5, :call5, :after5,
        :after
      ])
    end
  end

  context "when a before hook fails" do
    let(:organizer) {
      build_organizer(organize: [organizer2, interactor3, organizer4, interactor5]) do
        before do
          context.fail!
          context.steps << :before
        end

        after do
          context.steps << :after
        end
      end
    }

    it "aborts" do
      expect {
        organizer.call(context)
      }.not_to change {
        context.steps
      }
    end
  end

  context "when a before hook errors" do
    let(:organizer) {
      build_organizer(organize: [organizer2, interactor3, organizer4, interactor5]) do
        before do
          raise "foo"
          context.steps << :before
        end

        after do
          context.steps << :after
        end
      end
    }

    it "aborts" do
      expect {
        organizer.call(context) rescue nil
      }.not_to change {
        context.steps
      }
    end

    it "raises the error" do
      expect {
        organizer.call(context)
      }.to raise_error("foo")
    end
  end

  context "when an after hook fails" do
    let(:organizer) {
      build_organizer(organize: [organizer2, interactor3, organizer4, interactor5]) do
        before do
          context.steps << :before
        end

        after do
          context.fail!
          context.steps << :after
        end
      end
    }

    it "rolls back successfully called interactors" do
      expect {
        organizer.call(context)
      }.to change {
        context.steps
      }.from([]).to([
        :before,
          :before2,
            :before2a, :call2a, :after2a,
            :before2b, :call2b, :after2b,
            :before2c, :call2c, :after2c,
          :after2,
          :before3, :call3, :after3,
          :before4,
            :before4a, :call4a, :after4a,
            :before4b, :call4b, :after4b,
            :before4c, :call4c, :after4c,
          :after4,
          :before5, :call5, :after5,
        :rollback5,
        :rollback4c,
        :rollback4b,
        :rollback4a,
        :rollback3,
        :rollback2c,
        :rollback2b,
        :rollback2a
      ])
    end
  end

  context "when an after hook errors" do
    let(:organizer) {
      build_organizer(organize: [organizer2, interactor3, organizer4, interactor5]) do
        before do
          context.steps << :before
        end

        after do
          raise "foo"
          context.steps << :after
        end
      end
    }

    it "aborts" do
      expect {
        organizer.call(context) rescue nil
      }.to change {
        context.steps
      }.from([]).to([
        :before,
          :before2,
            :before2a, :call2a, :after2a,
            :before2b, :call2b, :after2b,
            :before2c, :call2c, :after2c,
          :after2,
          :before3, :call3, :after3,
          :before4,
            :before4a, :call4a, :after4a,
            :before4b, :call4b, :after4b,
            :before4c, :call4c, :after4c,
          :after4,
          :before5, :call5, :after5,
        :rollback5,
        :rollback4c,
        :rollback4b,
        :rollback4a,
        :rollback3,
        :rollback2c,
        :rollback2b,
        :rollback2a
      ])
    end

    it "raises the error" do
      expect {
        organizer.call(context)
      }.to raise_error("foo")
    end
  end

  context "when a nested before hook fails" do
    let(:interactor3) {
      build_interactor do
        before do
          context.fail!
          context.steps << :before3
        end

        after do
          context.steps << :after3
        end

        def call
          context.steps << :call3
        end

        def rollback
          context.steps << :rollback3
        end
      end
    }

    it "rolls back successfully called interactors" do
      expect {
        organizer.call(context)
      }.to change {
        context.steps
      }.from([]).to([
        :before,
          :before2,
            :before2a, :call2a, :after2a,
            :before2b, :call2b, :after2b,
            :before2c, :call2c, :after2c,
          :after2,
        :rollback2c,
        :rollback2b,
        :rollback2a
      ])
    end
  end

  context "when a nested before hook errors" do
    let(:interactor3) {
      build_interactor do
        before do
          raise "foo"
          context.steps << :before3
        end

        after do
          context.steps << :after3
        end

        def call
          context.steps << :call3
        end

        def rollback
          context.steps << :rollback3
        end
      end
    }

    it "rolls back successfully called interactors" do
      expect {
        organizer.call(context) rescue nil
      }.to change {
        context.steps
      }.from([]).to([
        :before,
          :before2,
            :before2a, :call2a, :after2a,
            :before2b, :call2b, :after2b,
            :before2c, :call2c, :after2c,
          :after2,
        :rollback2c,
        :rollback2b,
        :rollback2a
      ])
    end

    it "raises the error" do
      expect {
        organizer.call(context)
      }.to raise_error("foo")
    end
  end

  context "when a nested call fails" do
    let(:interactor3) {
      build_interactor do
        before do
          context.steps << :before3
        end

        after do
          context.steps << :after3
        end

        def call
          context.fail!
          context.steps << :call3
        end

        def rollback
          context.steps << :rollback3
        end
      end
    }

    it "rolls back successfully called interactors" do
      expect {
        organizer.call(context)
      }.to change {
        context.steps
      }.from([]).to([
        :before,
          :before2,
            :before2a, :call2a, :after2a,
            :before2b, :call2b, :after2b,
            :before2c, :call2c, :after2c,
          :after2,
          :before3,
        :rollback2c,
        :rollback2b,
        :rollback2a
      ])
    end
  end

  context "when a nested call errors" do
    let(:interactor3) {
      build_interactor do
        before do
          context.steps << :before3
        end

        after do
          context.steps << :after3
        end

        def call
          raise "foo"
          context.steps << :call3
        end

        def rollback
          context.steps << :rollback3
        end
      end
    }

    it "rolls back successfully called interactors" do
      expect {
        organizer.call(context) rescue nil
      }.to change {
        context.steps
      }.from([]).to([
        :before,
          :before2,
            :before2a, :call2a, :after2a,
            :before2b, :call2b, :after2b,
            :before2c, :call2c, :after2c,
          :after2,
          :before3,
        :rollback2c,
        :rollback2b,
        :rollback2a
      ])
    end

    it "raises the error" do
      expect {
        organizer.call(context)
      }.to raise_error("foo")
    end
  end

  context "when a nested after hook fails" do
    let(:interactor3) {
      build_interactor do
        before do
          context.steps << :before3
        end

        after do
          context.fail!
          context.steps << :after3
        end

        def call
          context.steps << :call3
        end

        def rollback
          context.steps << :rollback3
        end
      end
    }

    it "rolls back successfully called interactors and the failed interactor" do
      expect {
        organizer.call(context)
      }.to change {
        context.steps
      }.from([]).to([
        :before,
          :before2,
            :before2a, :call2a, :after2a,
            :before2b, :call2b, :after2b,
            :before2c, :call2c, :after2c,
          :after2,
          :before3, :call3,
        :rollback3,
        :rollback2c,
        :rollback2b,
        :rollback2a
      ])
    end
  end

  context "when a nested after hook errors" do
    let(:interactor3) {
      build_interactor do
        before do
          context.steps << :before3
        end

        after do
          raise "foo"
          context.steps << :after3
        end

        def call
          context.steps << :call3
        end

        def rollback
          context.steps << :rollback3
        end
      end
    }

    it "rolls back successfully called interactors and the failed interactor" do
      expect {
        organizer.call(context) rescue nil
      }.to change {
        context.steps
      }.from([]).to([
        :before,
          :before2,
            :before2a, :call2a, :after2a,
            :before2b, :call2b, :after2b,
            :before2c, :call2c, :after2c,
          :after2,
          :before3, :call3,
        :rollback3,
        :rollback2c,
        :rollback2b,
        :rollback2a
      ])
    end

    it "raises the error" do
      expect {
        organizer.call(context)
      }.to raise_error("foo")
    end
  end

  context "when a deeply nested before hook fails" do
    let(:interactor4b) {
      build_interactor do
        before do
          context.fail!
          context.steps << :before4b
        end

        after do
          context.steps << :after4b
        end

        def call
          context.steps << :call4b
        end

        def rollback
          context.steps << :rollback4b
        end
      end
    }

    it "rolls back successfully called interactors" do
      expect {
        organizer.call(context)
      }.to change {
        context.steps
      }.from([]).to([
        :before,
          :before2,
            :before2a, :call2a, :after2a,
            :before2b, :call2b, :after2b,
            :before2c, :call2c, :after2c,
          :after2,
          :before3, :call3, :after3,
          :before4,
            :before4a, :call4a, :after4a,
        :rollback4a,
        :rollback3,
        :rollback2c,
        :rollback2b,
        :rollback2a
      ])
    end
  end

  context "when a deeply nested before hook errors" do
    let(:interactor4b) {
      build_interactor do
        before do
          raise "foo"
          context.steps << :before4b
        end

        after do
          context.steps << :after4b
        end

        def call
          context.steps << :call4b
        end

        def rollback
          context.steps << :rollback4b
        end
      end
    }

    it "rolls back successfully called interactors" do
      expect {
        organizer.call(context) rescue nil
      }.to change {
        context.steps
      }.from([]).to([
        :before,
          :before2,
            :before2a, :call2a, :after2a,
            :before2b, :call2b, :after2b,
            :before2c, :call2c, :after2c,
          :after2,
          :before3, :call3, :after3,
          :before4,
            :before4a, :call4a, :after4a,
        :rollback4a,
        :rollback3,
        :rollback2c,
        :rollback2b,
        :rollback2a
      ])
    end

    it "raises the error" do
      expect {
        organizer.call(context)
      }.to raise_error("foo")
    end
  end

  context "when a deeply nested call fails" do
    let(:interactor4b) {
      build_interactor do
        before do
          context.steps << :before4b
        end

        after do
          context.steps << :after4b
        end

        def call
          context.fail!
          context.steps << :call4b
        end

        def rollback
          context.steps << :rollback4b
        end
      end
    }

    it "rolls back successfully called interactors" do
      expect {
        organizer.call(context)
      }.to change {
        context.steps
      }.from([]).to([
        :before,
          :before2,
            :before2a, :call2a, :after2a,
            :before2b, :call2b, :after2b,
            :before2c, :call2c, :after2c,
          :after2,
          :before3, :call3, :after3,
          :before4,
            :before4a, :call4a, :after4a,
            :before4b,
        :rollback4a,
        :rollback3,
        :rollback2c,
        :rollback2b,
        :rollback2a
      ])
    end
  end

  context "when a deeply nested call errors" do
    let(:interactor4b) {
      build_interactor do
        before do
          context.steps << :before4b
        end

        after do
          context.steps << :after4b
        end

        def call
          raise "foo"
          context.steps << :call4b
        end

        def rollback
          context.steps << :rollback4b
        end
      end
    }

    it "rolls back successfully called interactors" do
      expect {
        organizer.call(context) rescue nil
      }.to change {
        context.steps
      }.from([]).to([
        :before,
          :before2,
            :before2a, :call2a, :after2a,
            :before2b, :call2b, :after2b,
            :before2c, :call2c, :after2c,
          :after2,
          :before3, :call3, :after3,
          :before4,
            :before4a, :call4a, :after4a,
            :before4b,
        :rollback4a,
        :rollback3,
        :rollback2c,
        :rollback2b,
        :rollback2a
      ])
    end

    it "raises the error" do
      expect {
        organizer.call(context)
      }.to raise_error("foo")
    end
  end

  context "when a deeply nested after hook fails" do
    let(:interactor4b) {
      build_interactor do
        before do
          context.steps << :before4b
        end

        after do
          context.fail!
          context.steps << :after4b
        end

        def call
          context.steps << :call4b
        end

        def rollback
          context.steps << :rollback4b
        end
      end
    }

    it "rolls back successfully called interactors and the failed interactor" do
      expect {
        organizer.call(context)
      }.to change {
        context.steps
      }.from([]).to([
        :before,
          :before2,
            :before2a, :call2a, :after2a,
            :before2b, :call2b, :after2b,
            :before2c, :call2c, :after2c,
          :after2,
          :before3, :call3, :after3,
          :before4,
            :before4a, :call4a, :after4a,
            :before4b, :call4b,
        :rollback4b,
        :rollback4a,
        :rollback3,
        :rollback2c,
        :rollback2b,
        :rollback2a
      ])
    end
  end

  context "when a deeply nested after hook errors" do
    let(:interactor4b) {
      build_interactor do
        before do
          context.steps << :before4b
        end

        after do
          raise "foo"
          context.steps << :after4b
        end

        def call
          context.steps << :call4b
        end

        def rollback
          context.steps << :rollback4b
        end
      end
    }

    it "rolls back successfully called interactors and the failed interactor" do
      expect {
        organizer.call(context) rescue nil
      }.to change {
        context.steps
      }.from([]).to([
        :before,
          :before2,
            :before2a, :call2a, :after2a,
            :before2b, :call2b, :after2b,
            :before2c, :call2c, :after2c,
          :after2,
          :before3, :call3, :after3,
          :before4,
            :before4a, :call4a, :after4a,
            :before4b, :call4b,
        :rollback4b,
        :rollback4a,
        :rollback3,
        :rollback2c,
        :rollback2b,
        :rollback2a
      ])
    end

    it "raises the error" do
      expect {
        organizer.call(context)
      }.to raise_error("foo")
    end
  end
end
