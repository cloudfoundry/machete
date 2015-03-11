require 'bundler'
require 'machete/host/unknown/log'
require 'machete/host/unknown/db'

module Machete
  module Host
    class Unknown
      def create_log_manager
        Log.new(self)
      end

      def create_db_manager
        DB.new(self)
      end

      def run(command)
      end
    end
  end
end
