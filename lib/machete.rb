# encoding: utf-8
require 'machete/logger'
require 'machete/deploy_app'
require 'machete/cf'
require 'machete/app'
require 'machete/buildpack_mode'
require 'machete/vendor_dependencies'
require 'machete/setup_app'
require 'machete/app_status'
require 'machete/browser'

module Machete
  class << self
    def deploy_app(path, options = {})
      app = App.new(path, options)
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

    def deployer
      Machete::DeployApp.new
    end
  end
end
