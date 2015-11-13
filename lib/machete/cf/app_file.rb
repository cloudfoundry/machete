require 'machete/system_helper'

module Machete
  module CF
    class AppFile

      attr_reader :app

      def initialize(app)
        @app = app
      end

      def has_file?(filename)
        if app_has_diego_enabled?
          SystemHelper.run_cmd("cf ssh #{app.name} -c 'ls #{filename}'")
        else
          SystemHelper.run_cmd("cf files #{app.name} #{filename}")
        end
        SystemHelper.exit_status == 0
      end

      private

      def app_has_diego_enabled?
        SystemHelper.run_cmd("cf has-diego-enabled #{app.name}").chomp == 'true'
      end
    end
  end
end
