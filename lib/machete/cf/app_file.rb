require 'machete/system_helper'

module Machete
  module CF
    class AppFile

      attr_reader :app

      def initialize(app)
        @app = app
      end

      def has_file?(filename)
        file(filename)
        $?.exitstatus == 0
      end

      private

      def file(filename)
        SystemHelper.run_cmd("cf files #{app.name} #{filename}")
      end
    end
  end
end