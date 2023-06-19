# frozen_string_literal: true

require 'yaml'

module IBANTools
  class IBANRules
    def initialize(rules = {})
      @rules = rules
    end

    def [](key)
      @rules[key]
    end

    def self.defaults
      load_from_string(File.read("#{File.dirname(__FILE__)}/rules.yml"))
    end

    def self.load_from_string(string)
      rule_hash = YAML.safe_load(string)
      rule_hash.each do |_country_code, specs|
        specs['bban_pattern'] = Regexp.new("^#{specs['bban_pattern']}$")
      end
      IBANRules.new(rule_hash)
    end
  end
end
