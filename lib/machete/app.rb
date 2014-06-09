require 'httparty'
require 'machete/system_helper'
require 'json'

module Machete
  class App
    include SystemHelper

    attr_reader :output, :app_name, :manifest, :vendor_gems_before_push

    def initialize(app_path, opts={})
      @app_name = app_path.split("/").last
      @app_path = app_path
      @cmd = opts.fetch(:cmd, nil)
      @with_pg = opts.fetch(:with_pg, false)
      @database_name = opts.fetch(:database_name, "buildpacks")
      @manifest = opts.fetch(:manifest, nil)
      @vendor_gems_before_push = opts.fetch(:vendor_gems_before_push, false)
    end

    def directory_for_app
      "cf_spec/fixtures/#{@app_path}"
    end

    def push()
      Dir.chdir(directory_for_app) do
        generate_manifest

        if File.exists?("package.sh")
          Machete.logger.action('Vendoring dependencies before push')
          Bundler.with_clean_env do
            run_cmd('./package.sh')
          end
        end

        run_cmd("cf delete -f #{app_name}")

        command = "cf push #{app_name}"
        command += " -c '#{@cmd}'" if @cmd

        if with_pg?
          run_cmd("#{command} --no-start")
          run_cmd("cf set-env #{app_name} DATABASE_URL #{database_url}")
        end

        @output = run_cmd(command)

        Machete.logger.info "Output from command: #{command}\n" +
          @output
      end
    end

    def staging_log
      run_cmd("cf files #{app_name} logs/staging_task.log")
    end

    def cf_internet_log
      run_on_host("sudo cat /var/log/internet_access.log")
    end

    def homepage_html
      HTTParty.get("http://#{url}").body
    end

    def url
      run_cmd("cf app #{app_name} | grep url").split(' ').last
    end

    def has_file? filename
      run_cmd("cf files #{app_name} #{filename}")
      $?.exitstatus == 0
    end

    def staged?
      raw_spaces = run_cmd('cf curl /v2/spaces')
      spaces = JSON.parse(raw_spaces)
      test_space = spaces['resources'].detect { |resource| resource['entity']['name'] == 'integration' }
      apps_url = test_space['entity']['apps_url']

      raw_apps = run_cmd("cf curl #{apps_url}")
      apps = JSON.parse(raw_apps)
      app = apps['resources'].detect { |resource| resource['entity']['name'] == app_name }
      app['entity']['package_state'] == 'STAGED'
    end

    def logs
      run_cmd("cf logs #{app_name} --recent")
    end

    def with_pg?
      @with_pg
    end

    private

    def database_url
      "postgres://buildpacks:buildpacks@#{postgres_ip}:5524/#{@database_name}"
    end

    def postgres_ip
      ha_proxy_ip.gsub(/\d+\z/, "30")
    end

    def ha_proxy_ip
      @ha_proxy ||= run_cmd('cf api').scan(/api\.(\d+\.\d+\.\d+\.\d+)\.xip\.io/).flatten.first
    end

    def generate_manifest
      return unless manifest

      File.open('manifest.yml', 'w') do |manifest_file|
        manifest_file.write @manifest.to_yaml
      end
    end
  end
end
