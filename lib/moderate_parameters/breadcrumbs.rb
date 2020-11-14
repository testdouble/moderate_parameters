# frozen_string_literal: true

module ModerateParameters
  module Breadcrumbs
    def []=(key, _value)
      internal_param_logging(key, key?(key) ? 'overwritten' : 'added', caller_locations)
      super
    end

    def merge!(other_hash)
      internal_method_logging('merge!', other_hash.keys, caller_locations)
      super
    end

    def reverse_merge!(other_hash)
      internal_method_logging('reverse_merge!', other_hash.keys, caller_locations)
      super
    end

    def extract!(*keys)
      internal_method_logging('extract!', keys, caller_locations)
      super
    end

    def slice!(*keys)
      internal_method_logging('slice!', keys, caller_locations)
      super
    end

    def delete(*keys, &block)
      internal_method_logging('delete', keys, caller_locations)
      super
    end

    def reject!(&block)
      internal_block_logging('reject!', caller_locations)
      super
    end

    # Alias for #reject!
    def delete_if(&block)
      internal_block_logging('delete_if', caller_locations)
      super
    end

    def select!(&block)
      internal_block_logging('select!', caller_locations)
      super
    end

    # Alias for #select!
    def keep_if(&block)
      internal_block_logging('keep_if', caller_locations)
      super
    end

    private

    def needs_logged?
      instance_variable_get(:@moderate_params_object_id) && !permitted?
    end

    def internal_param_logging(key, action, stack_array)
      return unless ModerateParameters.breadcrumbs_enabled && needs_logged?

      ActiveSupport::Notifications.instrument('moderate_parameters') do |payload|
        payload[:caller_locations] = stack_array
        payload[:message] = "#{key} is being #{action} on: #{stack_array.join("\n")}"
      end
    end

    def internal_method_logging(method, args, stack_array)
      return unless ModerateParameters.breadcrumbs_enabled && needs_logged?

      ActiveSupport::Notifications.instrument('moderate_parameters') do |payload|
        payload[:caller_locations] = stack_array
        payload[:message] = "#{method} is being called with #{args} on: #{stack_array.join("\n")}"
      end
    end

    def internal_block_logging(method, stack_array)
      return unless ModerateParameters.breadcrumbs_enabled && needs_logged?

      ActiveSupport::Notifications.instrument('moderate_parameters') do |payload|
        payload[:caller_locations] = stack_array
        payload[:message] = "#{method} is being called with a block on: #{stack_array.join("\n")}"
      end
    end
  end
end
