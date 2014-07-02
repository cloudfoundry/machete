require 'httparty'
require 'machete/system_helper'

module Machete
  class AppController

    def deploy(app, options = {})
      env = options.fetch(:env, {})
      with_pg = options.fetch(:with_pg, false)
      database_name = options.fetch(:database_name, 'buildpacks')
      env['DATABASE_URL'] = database_url(database_name) if with_pg

      fixture = Fixture.new(app.path)

      Dir.chdir(fixture.directory) do
        clear_internet_access_log(app)
        fixture.vendor
        app.delete

        if env.any?
          app.push(start: false)
          setup_environment_variables(env, app)
        end

        app.push
      end
    end

    private

    def clear_internet_access_log(app)
      Host::Log.new(app.host).clear
    end

    def setup_environment_variables(env, app)
      env.each do |variable, value|
        app.set_env(variable.to_s, value)
      end
    end

    def database_url(database_name)
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
