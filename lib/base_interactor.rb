require "active_model"

module BaseInteractor
  def self.included(base)
    base.include ActiveModel::Validations
    base.extend ClassMethods

    base.before do
      context.fail!(errors: errors.full_messages_and_paths) unless valid?
    end
  end

  def read_attribute_for_validation(method_name)
    context.public_send(method_name)
  end

  module ClassMethods
    def requires(*args)
      validates_each args do |record, arg, _value|
        raise ArgumentError, "Required attribute #{arg} is missing on #{name}" unless record.context.to_h.key?(arg)
      end

      delegate(*args, to: :context)
    end
  end
end
