# frozen_string_literal: true

require 'rails/generators/base'

module ModerateParameters
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)

      desc 'Creates a ModerateParameters initializer.'

      def copy_initializer
        template 'moderate_parameters.rb', 'config/initializers/moderate_parameters.rb'
      end
    end
  end
end
