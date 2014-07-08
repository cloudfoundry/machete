module Machete
  class Database
    class UrlBuilder
      def execute(database_name:, server:)
        "#{server.type}://#{username}:#{password}@#{server.host}:#{server.port}/#{database_name}"
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
