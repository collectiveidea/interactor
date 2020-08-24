module TransactionableOrganizer
  extend ActiveSupport::Concern

  included do
    around do |organizer|
      ActiveRecord::Base.transaction do
        organizer.call(context)
      end

      if self.class.semaphore.present?
        self.class.semaphore.synchronize do
          instance_exec(&self.class.after_hook)
        end
      end

    rescue ActiveRecord::RecordInvalid => e
      context.fail!(errors: e.record.errors.full_messages_and_paths)
    rescue ActiveRecord::RecordNotDestroyed => e
      context.fail!(errors: e.record.errors.full_messages_and_paths)
    end
  end

  class_methods do
    attr_reader :after_hook, :semaphore

    protected

    def after_transaction(&block)
      @semaphore = Mutex.new

      @after_hook = block
    end

    def after
      raise "
        a TransactionableOrganizer should use a
        'after_transaction' hook instead of 'after'
      "
    end
  end
end
