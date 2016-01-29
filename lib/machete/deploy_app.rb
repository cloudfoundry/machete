# encoding: utf-8
require 'httparty'
require 'machete/system_helper'
require 'machete/cf/delete_app'

module Machete
  class DeployApp
    def execute(app, push_only: false)
      prepare_push(app) unless push_only

      push_app.execute(app)
    end

    private

    def prepare_push(app)
      delete_app.execute(app)
      vendor_dependencies.execute(app)
      setup_app(app)
    end

    def delete_app
      CF::DeleteApp.new
    end

    def push_app
      CF::PushApp.new
    end

    def setup_app(app)
      return unless app.needs_setup?
      push_app.execute(app, start: false)
      SetupApp.new.execute(app)
    end

    def vendor_dependencies
      VendorDependencies.new
    end
  end
end
