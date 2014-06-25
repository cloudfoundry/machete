require 'httparty'
require 'machete/system_helper'

module Machete
  class AppController
    attr_reader :output,
                :app_name,
                :app_path,
                :database_name,
                :vendor_gems_before_push,
                :cmd,
                :with_pg,
                :env,
                :app,
                :fixture

    def initialize(app, opts={})
      @app = app
      @app_name = app.name
      @app_path = app.path

      @cmd = opts.fetch(:cmd, nil)
      @with_pg = opts.fetch(:with_pg, false)
      @database_name = opts.fetch(:database_name, "buildpacks")
      @vendor_gems_before_push = opts.fetch(:vendor_gems_before_push, false)
      @env = opts.fetch(:env, {})

      @fixture = Machete::Fixture.new(app_path)
    end

    def push
      env['DATABASE_URL'] = database_url if with_pg

      Dir.chdir(fixture.directory) do
        clear_internet_access_log
        fixture.vendor
        app.delete
        app.push(start: env.empty?)
        setup_environment_variables
        @output = app.push
      end
    end

    # TODO: Add rspec matchers so there is no need to delegate here
    def staging_log
      app.file 'logs/staging_task.log'
    end

    def has_file? filename
      app.has_file? filename
    end
    ###################################

    private

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
