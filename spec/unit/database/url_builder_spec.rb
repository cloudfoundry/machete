require 'spec_helper'

module Machete
  class Database
    describe UrlBuilder do
      describe do
        let(:database_name) { 'database_name' }
        let(:port) { 'port'}
        let(:host) { 'host' }
        let(:database_type) { 'database_type' }
        let(:username) { Database::Settings.user_name }
        let(:password) { Database::Settings.user_password }
        let(:server) { double(:server, port: port, host: host, type: database_type) }

        let(:database_url) { "#{database_type}://#{username}:#{password}@#{host}:#{port}/#{database_name}" }

        subject(:database_url_builder) { UrlBuilder.new }

        specify do
          result = database_url_builder.execute(database_name: database_name, server: server)

          expect(result).to eql database_url
        end
      end
    end
  end
end
