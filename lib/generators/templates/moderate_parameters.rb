# frozen_string_literal: true

ModerateParameters.configure do |config|
  # Enables/Disables logging occurrences of
  # reading from ActionController::Parameters.
  config.breadcrumb_reads_enabled = false

  # Enables/Disables logging occurrences of
  # writing to ActionController::Parameters.
  config.breadcrumb_writes_enabled = false
end
