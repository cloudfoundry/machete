require 'machete/logger'
require 'machete/deploy_app'
require 'machete/app'
require 'machete/buildpack_mode'
require 'machete/cf'
require 'machete/host'
require 'machete/vendor_dependencies'
require 'machete/setup_app'
require 'machete/app_status'
require 'machete/browser'

module Machete
  class << self
    def deploy_app(path, options={})
      app = App.new(path, host, options)
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

    def logger=(new_logger)
      @logger = new_logger
    end

    private

    def deployer
      Machete::DeployApp.new
    end

    def host
      Host.create
    end
  end
end
