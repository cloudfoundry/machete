require 'ostruct'

module Machete
  module CF
    class Instances
      def initialize(app)
        @app = app
      end

      def execute
        return nil if error_occurred?

        instances
      end

      def error
        cf_response['error_code']
      end

      private

      attr_reader :app

      def cf_response
        @cf_response ||= JSON.parse instances_command
      end

      def error_occurred?
        cf_response.has_key?('error_code')
      end

      def instances
        cf_response.values.map do |instance|
          OpenStruct.new(instance)
        end
      end

      def instances_command
        SystemHelper.run_cmd("cf curl /v2/apps/#{app_guid}/instances")
      end

      def app_guid
        app_guid_finder.execute(app)
      end

      def app_guid_finder
        AppGuidFinder.new
      end
    end
  end
end
