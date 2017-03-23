# encoding: utf-8
require 'json'
require 'open3'

module Machete
  module SystemHelper
    def self.run_cmd(cmd, silent = false)
      Machete.logger.info "$ #{cmd}" unless silent
      result = `#{cmd}`
      Machete.logger.info result unless silent
      Machete.logger.error "Command '#{cmd}' failed.\n\noutput:\n\n#{result}" if exit_status != 0
      result
    end

    def self.exit_status
      $CHILD_STATUS.exitstatus
    end

    def self.cf_curl(url)
      o, s = Open3.capture2('cf', 'curl', url)
      raise "Could not cf curl #{url}" unless s.success?
      JSON.parse(o)
    end
  end
end
