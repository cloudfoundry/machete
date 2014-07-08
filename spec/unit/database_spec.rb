require 'spec_helper'

module Machete
  describe Database do
    let(:name) { 'name' }
    let(:host) { 'example.com' }
    let(:port) { 'port' }
    let(:server) { double(:server, host: host, port: port) }

    let(:password) { Database::Settings.superuser_password }
    let(:username) { Database::Settings.superuser_name }

    subject(:database) { Database.new(database_name: name, server: server) }

    describe '#clear' do
      before do
        allow(SystemHelper).
          to receive(:run_cmd).
               with("PGPASSWORD=#{password} psql -U #{username} -h #{host} -p #{port} -d postgres -c \"DROP DATABASE #{name}\"")
      end

      specify do
        database.clear
        expect(SystemHelper).to have_received(:run_cmd)
      end
    end

    describe '#create' do
      let(:owner) { Database::Settings.user_name }

      before do
        allow(SystemHelper).
          to receive(:run_cmd).
               with("PGPASSWORD=#{password} psql -U #{username} -h #{host} -p #{port} -d postgres -c \"CREATE DATABASE #{name} WITH OWNER #{owner}\"")
      end

      specify do
        database.create
        expect(SystemHelper).
          to have_received(:run_cmd)
      end
    end
  end
end
