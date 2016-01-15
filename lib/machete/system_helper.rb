module Machete
  module SystemHelper
    def self.run_cmd(cmd, silent=false)
      Machete.logger.info "$ #{cmd}" unless silent
      result = `#{cmd}`
      Machete.logger.info result unless silent
      Machete.logger.error "Command '#{cmd}' failed.\n\noutput:\n\n#{result}" if self.exit_status != 0
      result
    end

    def self.exit_status
      $?.exitstatus
    end
  end
end
