# frozen_string_literal: true

module IBANTools
  class Conversion
    def self.local2iban(country_code, data)
      config = load_config country_code

      bban = config.map do |key, values|
        d = data[key.to_sym].dup
        ret = [values].flatten.map do |value|
          l = bban_format_length(value)
          r = bban_format_to_format_string(value) % bban_format_cast(value, d[0..(l - 1)])
          d[0..(l - 1)] = ''
          r
        end.join('')
        # "%05s" % "a" -> "    a" and not "0000a"
        ret.gsub(/ /, '0')
      end.join('')

      check_digits = '%02d' % checksum(country_code, bban)

      IBAN.new "#{country_code}#{check_digits}#{bban}"
    end

    def self.iban2local(country_code, bban)
      config = load_config country_code

      local = {}
      config.map do |key, values|
        local[key.to_sym] = [values].flatten.map do |value|
          regexp = /^#{bban_format_to_regexp(value)}/
          ret = bban.scan(regexp).first
          bban.sub! regexp, ''
          ret
        end.join('')
        local[key.to_sym].sub!(/^0+/, '')
        local[key.to_sym] = '0' if local[key.to_sym] == ''
      end
      local
    end

    BBAN_REGEXP = /^(\d+)(!?)([nace])$/.freeze

    def self.bban_format_length(format)
      return ::Regexp.last_match(1).to_i if format =~ BBAN_REGEXP

      raise ArgumentError, "#{format} is not a valid bban format"
    end

    def self.bban_format_to_format_string(format)
      raise ArgumentError, "#{format} is not a valid bban format" unless format =~ BBAN_REGEXP
      return ' ' * ::Regexp.last_match(1).to_i if ::Regexp.last_match(3) == 'e'

      format = "%0#{::Regexp.last_match(1)}"
      format += case ::Regexp.last_match(3)
                when 'n' then 'd'
                when 'a' then 's'
                when 'c' then 's'
                end
      format
    end

    def self.bban_format_cast(format, value)
      raise ArgumentError, "#{format} is not a valid bban format" unless format =~ BBAN_REGEXP
      return value.to_i if ::Regexp.last_match(3) == 'n'

      value
    end

    def self.bban_format_to_regexp(format)
      raise ArgumentError, "#{format} is not a valid bban format" unless format =~ BBAN_REGEXP

      regexp = case ::Regexp.last_match(3)
               when 'n' then '[0-9]'
               when 'a' then '[A-Z]'
               when 'c' then '[a-zA-Z0-9]'
               when 'e' then '[ ]'
               end
      regexp += '{'
      regexp += ',' unless ::Regexp.last_match(2) == '!'
      regexp += "#{::Regexp.last_match(1)}}"
      regexp
    end

    def self.load_config(country_code)
      default_config = YAML
                       .load_file(File.join(File.dirname(__FILE__), 'conversion_rules.yml'))
      raise ArgumentError, "Country code #{country_code} not availble" unless default_config.key?(country_code)

      default_config[country_code]
    end

    def self.checksum(country_code, bban)
      97 - (IBAN.new("#{country_code}00#{bban}").numerify.to_i % 97) + 1
    end
  end
end
