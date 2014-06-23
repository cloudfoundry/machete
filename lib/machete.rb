require 'machete/logger'
require 'machete/app_controller'
require 'machete/app'
require 'machete/fixture'
require 'machete/buildpack_uploader'
require 'machete/buildpack_mode'
require 'machete/firewall'

module Machete
  class << self
    def deploy_app(app_path, options={})
      app_controller = Machete::AppController.new(app_path, options)
      app_controller.push
      yield app_controller if block_given?
      app_controller
    end

    def logger
      @logger ||= Machete::Logger.new(STDOUT)
    end

    def logger=(new_logger)
      @logger = new_logger
    end
  end
end

