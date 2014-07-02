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
      host = Host.new

      app = App.new(path, host, start_command: options.delete(:start_command))

      app_controller = Machete::AppController.new(app, options)
      app_controller.push
      app
    end

    def logger
      @logger ||= Machete::Logger.new(STDOUT)
    end

    def logger=(new_logger)
      @logger = new_logger
    end
  end
end