module Machete
  module Host
    class Aws
      class DB
        def initialize(host)
          @host = host
        end

        IP_REGEXP = Regexp.new(/((25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)\.){3}(25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)/)

        def run(command)
          @host.run "export PATH=/var/vcap/packages/postgres/bin:$PATH; #{command}", :postgres_z1
        end

        def hostname
          @hostname ||= begin
            Bundler.with_clean_env do
              output = SystemHelper.run_cmd 'bosh vms'
              postgres_host_line = output.split("\n").grep(/postgres/).first
              IP_REGEXP.match(postgres_host_line).to_s
            end
          end
        end

        def port
          5524
        end

        def type
          'postgres'
        end
      end
    end
  end
end

