require 'spec_helper'

module Machete
  describe Database do
    let(:name) { 'name' }
    let(:host) { 'example.com' }
    let(:port) { 'port' }
    let(:type) { 'postgres' }
    let(:database_manager) { double(:database_manager, hostname: host, port: port, type: type) }

    let(:password) { Database::Settings.superuser_password }
    let(:username) { Database::Settings.superuser_name }

    subject(:database) { Database.new(database_name: name, database_manager: database_manager) }

    describe '#create' do
      let(:owner) { Database::Settings.user_name }

      specify do
        expect(database_manager).
          to receive(:run).
               with("PGPASSWORD=machete psql -U machete -h example.com -p port -d postgres -c \"DROP DATABASE IF EXISTS name;\"; PGPASSWORD=machete psql -U machete -h example.com -p port -d postgres -c \"CREATE DATABASE name WITH OWNER buildpacks;\"")
        database.create
      end
    end
  end
end
