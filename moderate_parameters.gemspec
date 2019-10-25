# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'moderate_parameters/version'

Gem::Specification.new do |spec|
  spec.name        = 'moderate_parameters'
  spec.version     = ModerateParameters::VERSION
  spec.authors     = ['Kyle Boe']
  spec.email       = ['kyle@hint.io']

  spec.summary     = 'Protected Attributes to Strong Parameters migration tool'
  spec.description = 'A tool for migrating Rails applications from Protected ' \
                     'Attributes to Strong Parameters.'
  spec.homepage    = 'https://github.com/hintmedia/moderate_parameters'
  spec.license     = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/hintmedia/moderate_parameters'
    spec.metadata['changelog_uri'] = 'https://github.com/hintmedia/moderate_parameters/blob/master/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3.1'

  spec.add_dependency 'actionpack', '>= 3.0', '< 6.1'
  spec.add_dependency 'activemodel', '>= 3.0', '< 6.1'
  spec.add_dependency 'activesupport', '>= 3.0', '< 6.1'
  spec.add_dependency 'railties', '>= 3.0', '< 6.1'

  spec.add_development_dependency 'bundler', '~> 2.0.1'
  spec.add_development_dependency 'pry', '~> 0.12.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_junit_formatter', '0.4.1'
  spec.add_development_dependency 'appraisal', '2.2.0'
end
