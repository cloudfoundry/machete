module Machete
  class Host
    class Log
      attr_reader :host

      INTERNET_ACCESS_LOG = '/var/log/internet_access.log'

      def initialize(host)
        @host = host
      end

      def contents
        host.run cat_access_log_command
      end

      def clear
        host.run remove_access_log_command
        host.run restart_syslog_command
      end

      private

      def cat_access_log_command
        "sudo cat #{INTERNET_ACCESS_LOG}"
      end

      def remove_access_log_command
        "sudo rm #{INTERNET_ACCESS_LOG}"
      end

      def restart_syslog_command
        'sudo restart rsyslog'
      end
    end
  end
end