require 'httparty'
require 'machete/system_helper'
require 'machete/cf/delete_app'

module Machete
  class DeployApp
    def execute(app)
      clear_internet_access_log(app)
      delete_app.execute(app)
      vendor_dependencies.execute(app)

      if app.needs_setup?
        push_app.execute(app, start: false)
        setup_app.execute(app)
      end

      push_app.execute(app)
    end

    private

    def delete_app
      CF::DeleteApp.new
    end

    def push_app
      CF::PushApp.new
    end

    def setup_app
      SetupApp.new
    end

    def clear_internet_access_log(app)
      Host::Log.new(app.host).clear
    end

    def vendor_dependencies
      VendorDependencies.new
    end
  end
end
