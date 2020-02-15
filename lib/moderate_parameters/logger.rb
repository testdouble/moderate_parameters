# frozen_string_literal: true

ActiveSupport::Notifications.subscribe('moderate_parameters.default') do |_, _, _, _, payload|
  (ModerateParameters.logger || ActiveSupport::Logger.new('/dev/null')).info("#{payload[:controller]}##{payload[:action]} #{payload[:message]}")
end

ActiveSupport::Notifications.subscribe(/moderate_parameters\.breadcrumbs/) do |_, _, _, _, payload|
  (ModerateParameters.breadcrumb_logger || ModerateParameters.logger || ActiveSupport::Logger.new('/dev/null')).info(payload[:message])
end