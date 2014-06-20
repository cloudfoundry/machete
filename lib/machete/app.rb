require 'httparty'
require 'machete/system_helper'
require 'json'

module Machete
  class App
    include SystemHelper

    attr_reader :output,
                :app_name,
                :app_path,
                :manifest,
                :database_name,
                :vendor_gems_before_push,
                :cmd,
                :with_pg,
                :env

    def initialize(app_path, opts={})
      @app_name = app_path.split("/").last
      @app_path = app_path
      @cmd = opts.fetch(:cmd, nil)
      @with_pg = opts.fetch(:with_pg, false)
      @database_name = opts.fetch(:database_name, "buildpacks")
      @manifest = opts.fetch(:manifest, nil)
      @vendor_gems_before_push = opts.fetch(:vendor_gems_before_push, false)
      @env = opts.fetch(:env, {})
    end

    def push()
      env['DATABASE_URL'] = database_url if with_pg

      Dir.chdir(directory_for_app) do
        clear_internet_access_log
        generate_manifest
        vendor_dependencies
        delete_app
        push_app(start: env.empty?)
        setup_environment_variables
        @output = push_app
      end
    end

    def staging_log
      run_cmd("cf files #{app_name} logs/staging_task.log")
    end

    def cf_internet_log
      run_on_host('sudo cat /var/log/internet_access.log')
    end

    def homepage_html
      HTTParty.get("http://#{url}").body
    end

    def has_file? filename
      run_cmd("cf files #{app_name} #{filename}")
      $?.exitstatus == 0
    end

    def number_of_running_instances
      app_summary_url = app_resource['metadata']['url'] + '/summary'
      app = json("cf curl #{app_summary_url}")
      app['running_instances']
    end

    def logs
      run_cmd("cf logs #{app_name} --recent")
    end

    private

    def url
      run_cmd("cf app #{app_name} | grep url").split(' ').last
    end

    def directory_for_app
      "cf_spec/fixtures/#{app_path}"
    end

    def vendor_dependencies
      if File.exists?('package.sh')
        Machete.logger.action('Vendoring dependencies before push')
        Bundler.with_clean_env do
          run_cmd('./package.sh')
        end
      end
    end

    def push_app(options = {start: true})
      command = "cf push #{app_name}"
      command += " -c '#{cmd}'" if cmd
      command += " --no-start" unless options[:start]
      run_cmd command
    end

    def delete_app
      run_cmd("cf delete -f #{app_name}")
    end

    def setup_environment_variables
      env.each do |variable, value|
        run_cmd("cf set-env #{app_name} #{variable} #{value}")
      end
    end

    def database_url
      "postgres://buildpacks:buildpacks@#{postgres_ip}:5524/#{database_name}"
    end

    def postgres_ip
      ha_proxy_ip.gsub(/\d+\z/, '30')
    end

    def ha_proxy_ip
      @ha_proxy ||= run_cmd('cf api').scan(/api\.(\d+\.\d+\.\d+\.\d+)\.xip\.io/).flatten.first
    end

    def clear_internet_access_log
      run_on_host('sudo rm /var/log/internet_access.log')
      run_on_host('sudo restart rsyslog')
    end

    def generate_manifest
      return unless manifest

      File.open('manifest.yml', 'w') do |manifest_file|
        manifest_file.write @manifest.to_yaml
      end
    end

    def app_resource
      apps_response = json("cf curl /v2/apps?q='name:#{app_name}'")
      return if apps_response['total_results'] != 1
      apps_response['resources'].first
    end

    def json cmd
      JSON.parse run_cmd(cmd)
    end
  end
end
