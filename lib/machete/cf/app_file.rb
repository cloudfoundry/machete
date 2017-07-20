# encoding: utf-8
require 'machete/system_helper'

module Machete
  module CF
    class AppFile
      attr_reader :app

      def initialize(app)
        @app = app
      end

      def has_file?(filename)
        SystemHelper.run_cmd("cf ssh #{app.name} -c 'ls /app'")
        SystemHelper.run_cmd("cf ssh #{app.name} -c 'ls #{filename}'")
        SystemHelper.exit_status == 0
      end
    end
  end
end
