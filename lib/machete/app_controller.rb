require 'httparty'
require 'machete/system_helper'

module Machete
  class AppController


    def initialize(app, opts={})
      @app = app
      @fixture = Fixture.new(app.path)

      @with_pg = opts.fetch(:with_pg, false)
      @database_name = opts.fetch(:database_name, "buildpacks")
      @env = opts.fetch(:env, {})
    end

    def push
      env['DATABASE_URL'] = database_url if with_pg

      Dir.chdir(fixture.directory) do
        clear_internet_access_log
        fixture.vendor
        app.delete
        app.push(start: false) unless env.empty?
        setup_environment_variables
        app.push
      end
    end

    private

    attr_reader :database_name,
                :with_pg,
                :env,
                :app,
                :fixture

    def clear_internet_access_log
      Host::Log.new(app.host).clear
    end

    def setup_environment_variables
      env.each do |variable, value|
        app.set_env(variable.to_s, value)
      end
    end

    def database_url
      "postgres://buildpacks:buildpacks@#{postgres_ip}:5524/#{database_name}"
    end

    def postgres_ip
      ha_proxy_ip.gsub(/\d+\z/, '30')
    end

    def ha_proxy_ip
      @ha_proxy ||= SystemHelper.run_cmd('cf api').scan(/api\.(\d+\.\d+\.\d+\.\d+)\.xip\.io/).flatten.first
    end
  end
end
