# encoding: utf-8
require 'rspec/core/pending'

module Machete
  class RSpecHelpers
    include RSpec::Core::Pending
    class CfApiMatchError < StandardError
    end

    def self.skip_if_cf_api_below(version:, reason:)
      raise ArgumentError.new('you must supply a version') if version.nil?
      raise ArgumentError.new('you must supply a reason')  if reason.nil?

      cf_api_output = Machete::CF::API.new.execute
      m = cf_api_output.match(/API \s+ version: \s+ (\d+\.\d+\.\d+)/ix)
      unless m
        raise CfApiMatchError.new("Output was: #{cf_api_output}")
      end

      cf_api_version = m[1]
      minimum_acceptable_cf_api_version = Gem::Version.new(version)

      if Gem::Version.new(cf_api_version) < minimum_acceptable_cf_api_version
        self.new.skip(reason) # skip method is an instance method as defined by RSpec, so we have to new
      end
    end
  end
end

