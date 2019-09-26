# frozen_string_literal: true

module ModerateParameters
  module Breadcrumbs
    def [](key)
      internal_params_logging(key, caller_locations)
      super
    end

    private

    def internal_params_logging(key, stack_array)
      ActiveSupport::Notifications.instrument('moderate_parameters') do |payload|
        payload[:caller_locations] = stack_array
        payload[:message] = "#{key} is being read from: #{stack_array.join("\n")}"
      end
    end
  end
end
