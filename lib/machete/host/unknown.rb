require 'bundler'
require 'machete/host/unknown/log'

module Machete
  module Host
    class Unknown
      def create_log_manager
        Log.new(self)
      end

      def run(command)
      end
    end
  end
end
