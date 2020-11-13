# frozen_string_literal: true

module ModerateParameters
  module Breadcrumbs
    def []=(key, value)
      if ModerateParameters.breadcrumbs_enabled && permitted?
        internal_param_logging(key, 'overwritten', caller_locations)
      end
      super
    end

    def merge!(other_hash)
      if ModerateParameters.breadcrumbs_enabled && permitted?
        internal_method_logging('merge!', other_hash, caller_locations)
      end
      super
    end

    def reverse_merge!(other_hash)
      if ModerateParameters.breadcrumbs_enabled && permitted?
        internal_method_logging('reverse_merge!', other_hash, caller_locations)
      end
      super
    end

    def extract!(*keys)
      if ModerateParameters.breadcrumbs_enabled && permitted?
        internal_method_logging('extract!', keys, caller_locations)
      end
      super
    end

    def slice!(*keys)
      if ModerateParameters.breadcrumbs_enabled && permitted?
        internal_method_logging('slice!', keys, caller_locations)
      end
      super
    end

    def delete(*keys)
      if ModerateParameters.breadcrumbs_enabled && permitted?
        internal_method_logging('delete', keys, caller_locations)
      end
      super
    end

    def reject!(&block)
      if ModerateParameters.breadcrumbs_enabled && permitted?
        internal_method_logging('reject!', 'a block', caller_locations)
      end
      super
    end

    def select!(&block)
      if ModerateParameters.breadcrumbs_enabled && permitted?
        internal_method_logging('select!', 'a block', caller_locations)
      end
      super
    end

    private

    def internal_param_logging(key, action, stack_array)
      ActiveSupport::Notifications.instrument('moderate_parameters') do |payload|
        payload[:caller_locations] = stack_array
        payload[:message] = "#{key} is being #{action} on: #{stack_array.join("\n")}"
      end
    end

    def internal_method_logging(method, keys, stack_array)
      ActiveSupport::Notifications.instrument('moderate_parameters') do |payload|
        payload[:caller_locations] = stack_array
        payload[:message] = "#{method} is being called with #{keys} on: #{stack_array.join("\n")}"
      end
    end
  end
end
