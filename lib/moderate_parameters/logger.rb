# frozen_string_literal: true

$moderate_parameters_logger = ActiveSupport::Logger.new('log/moderate_parameters.log')

ActiveSupport::Notifications.subscribe('moderate_parameters') do |_, _, _, _, payload|
  $moderate_parameters_logger.info "#{payload[:controller]}##{payload[:action]} #{payload[:message]}"
end
