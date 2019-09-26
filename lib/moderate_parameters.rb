# frozen_string_literal: true

require 'action_controller'
require 'active_support'
require 'moderate_parameters/version'
require 'moderate_parameters/logger'
require 'moderate_parameters/parameters'
require 'moderate_parameters/breadcrumbs'

module ActionController
  class Parameters
    prepend ModerateParameters::Breadcrumbs
    prepend ModerateParameters::Parameters
  end
end
