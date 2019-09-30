# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/appmetrica/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-appmetrica'
  spec.version       = Fastlane::Appmetrica::VERSION
  spec.author        = 'Yandex, LLC'
  spec.email         = 'appmetrica@yandex-team.ru'

  spec.summary       = 'Upload dSYM symbolication files to AppMetrica'
  spec.homepage      = 'https://github.com/yandexmobile/metrica-plugin-fastlane'
  spec.license       = 'Nonstandard'

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane', '>= 2.131.0')
end
