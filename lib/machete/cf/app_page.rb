require 'httparty'

module Machete
  module CF
    class AppPage

      attr_reader :app

      def initialize(app)
        @app = app
      end

      def body
        HTTParty.get("http://#{url}").body
      end

      private

      def url
        SystemHelper.run_cmd("cf app #{app.name} | grep url").split(' ').last
      end
    end
  end
end