require 'bundler'
require 'shellwords'
require 'machete/host/aws/log'
require 'pty'

module Machete
  module Host
    class Aws
      START_FENCEPOST = '---COMMAND START---'
      STOP_FENCEPOST = '---COMMAND STOP---'

      def initialize()
        super
        @commands = []
      end

      def create_log_manager
        Log.new(self)
      end

      def queue_command(command)
        @commands << command
      end

      def run_queue
        run(@commands.join('; '))
        @commands = []
      end

      def run command
        command = command.join('; ') if command.is_a?(Array)
        raise("BOSH_TARGET must be set") unless ENV['BOSH_TARGET']

        Bundler.with_clean_env do
          PTY.spawn("bosh ssh runner_z1 --gateway_user vcap --gateway_host #{ENV['BOSH_TARGET']} --default_password p") do |output, input, pid|
            buffer = ''
            thread = Thread.new do
              while char = output.read(1)
                buffer += char
              end
            end

            rsa_accepted = false
            loop do
              sleep(0.01)
              if !rsa_accepted && buffer.include?('connecting (yes/no)? ')
                input.write("yes\n")
                rsa_accepted = true
              end
              break if buffer.include?(':~$ ')
            end

            input.write("echo '#{START_FENCEPOST}'; #{command}; echo '#{STOP_FENCEPOST}'\n")
            sleep(0.01) until buffer.match(/#{STOP_FENCEPOST}\r?\n/)
            thread.kill
            return buffer.match(/#{START_FENCEPOST}\r?\n(.*)#{STOP_FENCEPOST}/m)[1]
          end
        end
      end
    end
  end
end
