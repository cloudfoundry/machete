require 'shellwords'

module Machete
  module Host
    class Vagrant
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

        def logged_internet_traffic?
          contents.include?('cf-to-internet-traffic')
        end

        private

        def cat_access_log_command
          "sudo cat #{INTERNET_ACCESS_LOG}"
        end

        def remove_access_log_command
          command = "rm -f #{INTERNET_ACCESS_LOG} && touch #{INTERNET_ACCESS_LOG} && chown syslog:adm #{INTERNET_ACCESS_LOG} && chmod 666 #{INTERNET_ACCESS_LOG}"
          "sudo bash -c #{command.shellescape}"
        end

        def restart_syslog_command
          'sudo restart rsyslog'
        end
      end
    end
  end
end
