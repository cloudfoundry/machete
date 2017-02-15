# encoding: utf-8
require 'ostruct'

module Machete
  module CF
    class Stacks
      def execute
        stacks
      end

      private

      def cf_response
        @cf_response ||= JSON.parse stacks_command
      end

      def stacks
        cf_response['resources'].map do |stack|
          stack.dig('entity','name')
        end
      end

      def stacks_command
        SystemHelper.run_cmd("cf curl /v2/stacks")
      end
    end
  end
end
