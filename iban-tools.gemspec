# frozen_string_literal: true

Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY
  s.summary      = 'IBAN validator'
  s.name         = 'iban_tools'
  s.version      = '0.0.7'
  s.authors      = ['Iulian Dogariu']
  s.email        = ['code@iuliandogariu.com']
  s.requirements << 'none'
  s.require_path = 'lib'
  s.files        = [
    'README.md',
    'lib/iban_tools.rb',
    'lib/iban_tools/iban.rb',
    'lib/iban_tools/iban_rules.rb',
    'lib/iban_tools/rules.yml'
  ]
  s.description = 'Validates IBAN account numbers'

  s.required_ruby_version = '> 2.7'
end
