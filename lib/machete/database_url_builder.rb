module Machete
  class DatabaseUrlBuilder
    DATABASE_HOST_OCTET = '30'
    DATABASE_PORT = '5524'
    IP_ADDRESS_REGEX = /(\d+\.\d+\.\d+\.)\d+/

    def execute(options = {})
      database_type = 'postgres'
      username = 'buildpacks'
      password = 'buildpacks'
      database_name = options[:database_name] || 'buildpacks'

      "#{database_type}://#{username}:#{password}@#{database_ip}:#{DATABASE_PORT}/#{database_name}"
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
