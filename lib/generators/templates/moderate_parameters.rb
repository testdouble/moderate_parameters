# frozen_string_literal: true

ModerateParameters.configure do |config|
  # Enables/Disables logging occurrences of
  # reading/writing from ActionController::Parameters.
  config.breadcrumbs_enabled = false
  # Sets where to log the ModerateParameters output
  config.logger = ActiveSupport::Logger.new('log/moderate_parameters.log')
end
