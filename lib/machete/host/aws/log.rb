module Machete
  module Host
    class Aws
      class Log
        attr_reader :host

        INTERNET_ACCESS_LOG = '/var/log/messages'

        def initialize(host)
          @host = host
        end

        def contents
          host.run cat_access_log_command
        end

        def clear
          host.run [remove_access_log_command, restart_syslog_command]
        end

        def logged_internet_traffic?
          contents.include?('OUT=eth0')
        end

        private

        def cat_access_log_command
          invoke_sudo_with_command "cat #{INTERNET_ACCESS_LOG}"
        end

        def remove_access_log_command
          invoke_sudo_with_command "rm #{INTERNET_ACCESS_LOG}"
        end

        def restart_syslog_command
          invoke_sudo_with_command "restart rsyslog"
        end

        def invoke_sudo_with_command(command)
          "echo p | sudo -S #{command}"
        end
      end
    end
  end
end
