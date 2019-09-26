# frozen_string_literal: true

module ModerateParameters
  module Parameters
    def moderate(controller_name, action, *filters)
      params = self.class.new

      filters.each do |filter|
        case filter
        when Symbol, String
          permitted_scalar_filter(params, filter)
        when Hash
          cust_hash_filter(params, filter, controller_name, action)
        end
      end

      incoming_params_logging(params, controller_name, action)
      permit!
    end

    private

    def incoming_params_logging(params, controller_name, action)
      unpermitted_keys(params).each do |k|
        ActiveSupport::Notifications.instrument('moderate_parameters') do |payload|
          payload[:controller] = controller_name
          payload[:action] = action
          payload[:message] = "#{@context || 'Top Level'} is missing: #{k}"
        end
      end
    end

    def non_scalar?(value)
      value.is_a?(Array) || value.is_a?(Parameters)
    end

    EMPTY_HASH = {}
    def cust_hash_filter(params, filter, controller_name, action)
      filter = filter.with_indifferent_access

      # Slicing filters out non-declared keys.
      slice(*filter.keys).each do |key, value|
        next unless value
        next unless has_key? key

        if filter[key] == EMPTY_ARRAY
          # Declaration { comment_ids: [] }.
          array_of_permitted_scalars?(self[key]) do |val|
            params[key] = val
          end
        elsif filter[key] == EMPTY_HASH
          # Declaration { preferences: {} }.
          if value.is_a?(Parameters)
            params[key] = permit_any_in_parameters(value)
          end
        elsif non_scalar?(value)
          # Declaration { user: :name } or { user: [:name, :age, { address: ... }] }.
          params[key] = each_element(value) do |element|
            element.instance_variable_set '@context', "Parent #{key}"
            element.moderate(controller_name, action, *Array.wrap(filter[key]))
          end
        end
      end
    end
  end
end
