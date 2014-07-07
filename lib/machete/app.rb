require 'machete/system_helper'
require 'httparty'

module Machete
  class App
    FIXTURES_DIR = 'cf_spec/fixtures'

    attr_reader :name,
                :path,
                :host,
                :start_command

    def initialize path, host, options = {}
      @path = path
      @host = host

      @name = path.split('/').last
      @start_command = options[:start_command]
      @with_pg = options[:with_pg]
      @database_name = options[:database_name]
      @env = options.fetch(:env, {})
    end

    def src_directory
      FIXTURES_DIR + '/' + path
    end

    def environment_variables?
      env.any?
    end

    def env
      if with_pg
        database_configuration.merge @env
      else
        @env
      end
    end

    private

    attr_reader :with_pg,
                :database_name

    def database_configuration
      {
        'DATABASE_URL' => database_url
      } 
    end

    def database_url
      @database_url ||= database_url_builder.execute(database_name: database_name)
    end

    def database_url_builder
      DatabaseUrlBuilder.new
    end
  end
end
