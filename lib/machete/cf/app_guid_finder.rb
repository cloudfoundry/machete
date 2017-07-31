# encoding: utf-8
require 'json'

module Machete
  module CF
    class AppGuidFinder
      def execute(app)
        extract_first_guid search(app.name)
      end

      private

      def extract_first_guid(response)
        response['resources'].first['metadata']['guid']
      rescue
        nil
      end

      def search(app_name)
        JSON.parse cf_response(app_name)
      end

      def cf_response(app_name)
        SystemHelper.run_cmd(find_app_command(app_name), true)
      end

      def find_app_command(app_name)
        space = space_guid
        if space
          "cf curl '/v2/apps?q=space_guid:#{space}&q=name:#{app_name}'"
        else
          "cf curl '/v2/apps?q=name:#{app_name}'"
        end
      end

      def space_guid
        data = JSON.parse(File.read("#{cf_home}/.cf/config.json")) rescue {}
        data.dig('SpaceFields', 'GUID')
      end

      def cf_home
        ENV.fetch('CF_HOME', ENV.fetch('HOME'))
      end
    end
  end
end
