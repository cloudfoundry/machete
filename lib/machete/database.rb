require 'machete/database/server'
require 'machete/database/url_builder'
require 'machete/database/settings'

module Machete
  class Database
    def initialize(database_name:, server:)
      @database_name = database_name
      @server = server
    end

    def clear
      SystemHelper.run_cmd psql(drop_database_command)
    end

    def create
      SystemHelper.run_cmd psql(create_database_command)
    end

    private

    attr_reader :database_name,
                :server

    def drop_database_command
      "DROP DATABASE #{database_name}"
    end

    def create_database_command
      "CREATE DATABASE #{database_name} WITH OWNER #{Settings.user_name}"
    end

    def psql(sql)
      command = "PGPASSWORD=#{Settings.superuser_password} psql"
      command += " -U #{Settings.superuser_name}"
      command += " -h #{host}"
      command += " -p #{port}"
      command += " -d #{connecting_database}"
      command + " -c \"#{sql}\""
    end

    def host
      server.host
    end

    def port
      server.port
    end

    def connecting_database
      'postgres'
    end
  end
end
