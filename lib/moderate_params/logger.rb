# frozen_string_literal: true

$moderate_params_logger = Logger.new("#{Rails.root}/log/moderate_params.log")

ActiveSupport::Notifications.subscribe('moderate_params') do |name, start, finish, id, payload|
  $moderate_params_logger.info "#{payload[:controller]}##{payload[:action]} #{payload[:message]}"
end