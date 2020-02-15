# frozen_string_literal: true

module ModerateParameters
  module Breadcrumbs
    def []=(key, value)
      internal_param_logging(key, 'overwritten', caller_locations) if ModerateParameters.breadcrumbs_enabled
      super
    end

    def extract!(*keys)
      internal_method_logging('extract!', keys, caller_locations) if ModerateParameters.breadcrumbs_enabled
      super
    end

    def slice!(*keys)
      internal_method_logging('slice!', keys, caller_locations) if ModerateParameters.breadcrumbs_enabled
      super
    end

    private

    def internal_param_logging(key, action, stack_array)
      ActiveSupport::Notifications.instrument("moderate_parameters.breadcrumbs.[]=") do |payload|
        payload[:caller_locations] = stack_array
        payload[:message] = "#{key} is being #{action} on: #{stack_array.join("\n")}"
      end
    end

    def internal_method_logging(method, keys, stack_array)
      ActiveSupport::Notifications.instrument("moderate_parameters.breadcrumbs.#{method}") do |payload|
        payload[:caller_locations] = stack_array
        payload[:message] = "#{method} is being called with #{keys} on: #{stack_array.join("\n")}"
      end
    end
  end
end
