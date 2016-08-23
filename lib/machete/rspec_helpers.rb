# encoding: utf-8
require 'rspec/core/pending'

module Machete
  class RSpecHelpers
    include RSpec::Core::Pending

    def self.skip_if_cf_api_below(version: nil, reason: nil)
      raise ArgumentError.new('you must supply a version') if version.nil?
      raise ArgumentError.new('you must supply a reason')  if reason.nil?

      cf_api_output = Machete::CF::API.new.execute

      cf_api_version = cf_api_output.match( /API version: (?<version_number>\d+\.\d+\.\d+)/ )['version_number']
      minimum_acceptable_cf_api_version = Gem::Version.new(version)

      if Gem::Version.new(cf_api_version) < minimum_acceptable_cf_api_version
        self.new.skip(reason) # skip method is an instance method as defined by RSpec, so we have to new
      end
    end

    def self.skip_if_proprietary_dependencies_are_not_available
      oracle_proprietary_files = %w(
        /oracle/libclntshcore.so.12.1
        /oracle/libclntsh.so
        /oracle/libclntsh.so.12.1
        /oracle/libipc1.so
        /oracle/libmql1.so
        /oracle/libnnz12.so
        /oracle/libociicus.so
        /oracle/libons.so
      )

      all_files_were_found = oracle_proprietary_files.reduce { |all_found_so_far, file_to_check| all_found_so_far && File.exist?(file_to_check) }

      self.new.skip('Skipping Oracle module tests as proprietary files are missing') unless all_files_were_found
    end
  end
end

