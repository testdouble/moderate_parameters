# frozen_string_literal: true

module ModerateParameters
  module Parameters
    def moderate(controller_name, action, *filters)
      params = self.class.new

      filters.each do |filter|
        case filter
        when Symbol, String
          if non_scalar?(self[filter])
            non_scalar_value_filter(params, filter, controller_name, action)
          else
            permitted_scalar_filter(params, filter)
          end
        when Hash
          cust_hash_filter(params, filter, controller_name, action)
        end
      end

      incoming_params_logging(params, controller_name, action)
      dup.permit!
    end

    private

    def write_to_log(options)
      ActiveSupport::Notifications.instrument('moderate_parameters.default') do |payload|
        payload.merge!(options)
      end
    end

    def incoming_params_logging(params, controller_name, action)
      unpermitted_keys(params).each do |k|
        write_to_log(message: "#{@context || 'Top Level'} is missing: #{k}",
                     action: action,
                     controller: controller_name)
      end
    end

    def non_scalar_value_filter(params, key, controller_name, action)
      if has_key?(key) && !permitted_scalar?(self[key])
        params[key] = self[key].class.new
        write_to_log(message: "#{@context || 'Top Level'} is missing: #{params[key]} value for #{key}",
                     action: action,
                     controller: controller_name)
      end
    end

    def array_of_permitted_scalars?(value)
      if value.is_a?(Array) && value.all? { |element| permitted_scalar?(element) }
        yield value
      end
    end

    def non_scalar?(value)
      value.is_a?(Array) || value.is_a?(Parameters)
    end

    def permit_any_in_array(array)
      [].tap do |sanitized|
        array.each do |element|
          case element
          when ->(e) { permitted_scalar?(e) }
            sanitized << element
          when Parameters
            sanitized << permit_any_in_parameters(element)
          else
            # Log it
          end
        end
      end
    end

    def permit_any_in_parameters(params)
      self.class.new.tap do |sanitized|
        params.each do |key, value|
          case value
          when ->(v) { permitted_scalar?(v) }
            sanitized[key] = value
          when Array
            sanitized[key] = permit_any_in_array(value)
          when Parameters
            sanitized[key] = permit_any_in_parameters(value)
          else
            # Log It
          end
        end
      end
    end

    EMPTY_HASH ||= {}
    EMPTY_ARRAY ||= []
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
