# encoding: utf-8
require 'rspec/core/pending'

module Machete
  class RSpecHelpers
    include RSpec::Core::Pending

    def self.skip_if_cf_api_below(version: nil, reason: nil)
      raise ArgumentError.new('you must supply a version') if version.nil?
      raise ArgumentError.new('you must supply a reason')  if reason.nil?

      cf_api_output = Machete::CF::API.new.execute

      cf_api_version = cf_api_output.match( /API version:\s*(?<version_number>\d+\.\d+\.\d+)/ )['version_number']
      minimum_acceptable_cf_api_version = Gem::Version.new(version)

      if Gem::Version.new(cf_api_version) < minimum_acceptable_cf_api_version
        self.new.skip(reason) # skip method is an instance method as defined by RSpec, so we have to new
      end
    end
  end
end

