# frozen_string_literal: true

ActiveSupport::Notifications.subscribe('moderate_parameters') do |_, _, _, _, payload|
  (ModerateParameters.logger || ActiveSupport::Logger.new('/dev/null')).info "#{payload[:controller]}##{payload[:action]} #{payload[:message]}"
end
