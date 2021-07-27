# frozen_string_literal: true

module TooSimple
  class FullNameAction < BaseAction
    delegate :first_name, :last_name, to: :context

    def call
      guard_any(:first_name, :last_name)

      context.full_name = if first_name.nil?
                            last_name
                          elsif last_name.nil?
                            first_name
                          else
                            "#{first_name} #{last_name}"
                          end
    end
  end
end