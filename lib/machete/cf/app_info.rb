require 'machete/system_helper'
require 'json'

module Machete
  module CF
    class AppInfo

      attr_reader :app

      def initialize(app)
        @app = app
      end

      def instance_count
        app_info['running_instances']
      end

      private

      def app_info
        decode app_summary_command
      end

      def app_summary_command
        "cf curl #{app_resource_url}/summary"
      end

      def app_resource_url
        app_search_result['metadata']['url']
      end

      def app_search_result
        search_results = decode(app_search_command)
        return if search_results['total_results'] != 1
        search_results['resources'].first
      end

      def app_search_command
        "cf curl /v2/apps?q='name:#{app.name}'"
      end

      def decode cmd
        JSON.parse SystemHelper.run_cmd(cmd, true)
      end
    end
  end
end