# frozen_string_literal: true

module ModerateParameters
  module Breadcrumbs
    def [](key)
      internal_params_logging(key, 'read', caller_locations)
      super
    end

    def []=(key, value)
      internal_params_logging(key, 'overwritten', caller_locations)
      super
    end

    private

    def internal_params_logging(key, action, stack_array)
      ActiveSupport::Notifications.instrument('moderate_parameters') do |payload|
        payload[:caller_locations] = stack_array
        payload[:message] = "#{key} is being #{action} on: #{stack_array.join("\n")}"
      end
    end
  end
end
