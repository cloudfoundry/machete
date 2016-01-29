# encoding: utf-8
module Machete
  class Database
    module Settings
      def self.user_name
        'buildpacks'
      end

      def self.user_password
        'buildpacks'
      end

      def self.superuser_name
        'machete'
      end

      def self.superuser_password
        'machete'
      end
    end
  end
end
