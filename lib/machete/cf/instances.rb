# encoding: utf-8
require 'ostruct'

module Machete
  module CF
    class Instances
      def initialize(app)
        @app = app
      end

      def execute
        return [] if error_occurred?

        instances
      end

      def error
        return 'NoAppGUID' if app.guid.nil?
        cf_response['error_code']
      end

      private

      attr_reader :app

      def cf_response
        @cf_response ||= SystemHelper.cf_curl("/v2/apps/#{app.guid}/instances")
      end

      def error_occurred?
        app.guid.nil? || cf_response.key?('error_code')
      end

      def instances
        cf_response.values.map do |instance|
          OpenStruct.new(instance)
        end
      end
    end
  end
end
