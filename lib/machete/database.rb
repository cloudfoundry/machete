require 'machete/database/url_builder'
require 'machete/database/settings'

module Machete
  class Database
    def initialize(database_name:, database_manager:)
      @database_name = database_name
      @database_manager = database_manager
    end

    def create
      @database_manager.run [
        psql(drop_database_command),
        psql(create_database_command)
      ].join("; ")
    end

    private

    def database_name
      @database_name
    end

    def drop_database_command
      "DROP DATABASE IF EXISTS #{database_name};"
    end

    def create_database_command
      "CREATE DATABASE #{database_name} WITH OWNER #{Settings.user_name};"
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
      @database_manager.hostname
    end

    def port
      @database_manager.port
    end

    def connecting_database
      @database_manager.type
    end
  end
end
