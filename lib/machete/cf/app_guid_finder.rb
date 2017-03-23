# encoding: utf-8
require 'json'
require 'open3'

module Machete
  module CF
    class AppGuidFinder
      def execute(app)
        data = curl(find_app_command(app.name))
        data.dig('resources', 0, 'metadata', 'guid')
      end

      private

      def space_guid
        data = JSON.parse(File.read("#{ENV['HOME']}/.cf/config.json")) rescue {}
        data.dig('SpaceFields', 'GUID')
      end

      def find_app_command(app_name)
        space = space_guid
        if space
          "/v2/apps?q=space_guid:#{space}&q=name:#{app_name}"
        else
          "/v2/apps?q=name:#{app_name}"
        end
      end

      def curl(url)
        o, s = Open3.capture2('cf', 'curl', url)
        raise "Could not cf curl #{url}" unless s.success?
        JSON.parse(o)
      end
    end
  end
end
