module Machete
  module Host
    class Vagrant
      class DB
        DATABASE_HOST_OCTET = '30'
        IP_ADDRESS_REGEX = /(\d+\.\d+\.\d+\.)\d+/

        def initialize(host)
          @host = host
        end

        def run(command)
          SystemHelper.run_cmd command
        end

        def hostname
          @hostname ||= database_ip
        end

        def port
          5524
        end

        def type
          'postgres'
        end

        private

        def database_ip
          cf_base_ip + DATABASE_HOST_OCTET
        end


        def cf_base_ip
          ha_proxy_ip.slice(IP_ADDRESS_REGEX, 1)
        end

        def ha_proxy_ip
          CF::API.new.execute
        end
      end
    end
  end
end
