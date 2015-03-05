require 'spec_helper'

module Machete
  class Database
    describe UrlBuilder do
      describe do
        let(:database_name) { 'database_name' }
        let(:port) { 'port'}
        let(:hostname) { 'hostname' }
        let(:database_type) { 'database_type' }
        let(:username) { Database::Settings.user_name }
        let(:password) { Database::Settings.user_password }
        let(:database_manager) { double(:database_manager, port: port, hostname: hostname, type: database_type) }

        let(:database_url) { "#{database_type}://#{username}:#{password}@#{hostname}:#{port}/#{database_name}" }

        subject(:database_url_builder) { UrlBuilder.new }

        specify do
          result = database_url_builder.execute(database_name: database_name, database_manager: database_manager)

          expect(result).to eql database_url
        end
      end
    end
  end
end
