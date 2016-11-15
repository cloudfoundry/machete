# encoding: utf-8
require 'machete/logger'
require 'machete/deploy_app'
require 'machete/cf'
require 'machete/rspec_helpers'
require 'machete/app'
require 'machete/buildpack_mode'
require 'machete/vendor_dependencies'
require 'machete/setup_app'
require 'machete/app_status'
require 'machete/browser'
require 'machete/buildpack_test_runner'

module Machete
  class << self
    def deploy_app(path, options = {})
      app = App.new(path, options)
      raise "Unable to locate app directory: #{app.src_directory}" unless directory_exists? app.src_directory
      deployer.execute(app)
      app
    end

    # Pushes an existing app again
    def push(app)
      deployer.execute(app, push_only: true)
    end

    def logger
      @logger ||= Machete::Logger.new(STDOUT)
    end

    attr_writer :logger

    private

    def directory_exists?(directory)
      !(`file #{directory}`.include? 'No such file or directory')
    end

    def deployer
      Machete::DeployApp.new
    end
  end
end
