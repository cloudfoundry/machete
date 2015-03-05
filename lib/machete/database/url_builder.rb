module Machete
  class Database
    class UrlBuilder
      def execute(database_name:, database_manager:)
        "#{database_manager.type}://#{username}:#{password}@#{database_manager.hostname}:#{database_manager.port}/#{database_name}"
      end

      private

      def username
        Settings.user_name
      end

      def password
        Settings.user_password
      end
    end
  end
end
