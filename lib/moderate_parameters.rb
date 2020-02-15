# frozen_string_literal: true

require 'action_controller'
require 'active_support'
require 'moderate_parameters/version'
require 'moderate_parameters/parameters'
require 'moderate_parameters/breadcrumbs'

module ModerateParameters
  mattr_accessor :breadcrumbs_enabled
  @@breadcrumbs_enabled = false

  mattr_accessor :logger
  @@logger = nil

  mattr_accessor :breadcrumb_logger
  @@breadcrumb_logger = nil

  def self.configure
    yield self
  end
end

module ActionController
  class Parameters
    prepend ModerateParameters::Breadcrumbs
    prepend ModerateParameters::Parameters
  end
end

require 'moderate_parameters/logger'
