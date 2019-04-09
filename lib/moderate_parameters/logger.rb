# frozen_string_literal: true
file = File.open("#{Rails.root}/log/moderate_parameters.log", File::WRONLY | File::APPEND)
$moderate_parameters_logger = Logger.new(file)

ActiveSupport::Notifications.subscribe('moderate_parameters') do |name, start, finish, id, payload|
  $moderate_parameters_logger.info "#{payload[:controller]}##{payload[:action]} #{payload[:message]}"
end