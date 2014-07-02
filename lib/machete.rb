require 'machete/logger'
require 'machete/app_controller'
require 'machete/app'
require 'machete/fixture'
require 'machete/buildpack_uploader'
require 'machete/buildpack_mode'
require 'machete/firewall'
require 'machete/cf'
require 'machete/host'

module Machete
  class << self
    def deploy_app(path, options={})
      start_command = options.delete(:start_command)
      app = App.new(path, host, start_command: start_command)
      app_controller.deploy(app, options)
      app
    end

    def logger
      @logger ||= Machete::Logger.new(STDOUT)
    end

    def logger=(new_logger)
      @logger = new_logger
    end

    private

    def app_controller
      Machete::AppController.new
    end

    def host
      Host.new
    end
  end
end