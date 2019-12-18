# frozen_string_literal: true

$moderate_parameters_logger = ModerateParameters.logger

ActiveSupport::Notifications.subscribe('moderate_parameters') do |_, _, _, _, payload|
  $moderate_parameters_logger.info "#{payload[:controller]}##{payload[:action]} #{payload[:message]}"
end
