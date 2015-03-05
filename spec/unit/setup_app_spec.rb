require 'spec_helper'

module Machete
  describe SetupApp do
    let(:database) { double(:database) }
    let(:host) { double(:host) }
    let(:app) { double(:app, host: host, name: app_name, with_pg: with_pg, env: env) }
    let(:app_name) { double(:app_name) }
    let(:env) { double(:env) }
    let(:database_url) { double(:database_url) }
    let(:set_app_env) { double(:set_app_env) }

    subject(:setup_app) { SetupApp.new }

    before do
      allow(CF::SetAppEnv).
        to receive(:new).
             and_return(set_app_env)

      allow(set_app_env).
        to receive(:execute).
             with(app)
    end

    context 'app does not require database' do
      let(:with_pg) { false }

      specify do
        expect(Database).not_to receive(:new)

        setup_app.execute(app)

        expect(set_app_env).
          to have_received(:execute).
               with(app)
      end
    end

    context 'app requires database' do
      let(:with_pg) { true }
      let(:database_manager) { double(:database_manager) }
      let(:url_builder) { double(:url_builder) }

      before do
        allow(app.host).
          to receive(:create_db_manager).
               and_return(database_manager)

        allow(Database).
          to receive(:new).
               with(database_name: app_name, database_manager: database_manager).
               and_return(database)

        allow(database).
          to receive(:clear).
               with(no_args)

        allow(database).
          to receive(:create).
               with(no_args)

        allow(Database::UrlBuilder).
          to receive(:new).
               and_return(url_builder)

        allow(url_builder).
          to receive(:execute).
               with(database_name: app_name, database_manager: database_manager).
               and_return(database_url)

        allow(env).
          to receive(:[]=).
               with('DATABASE_URL', database_url)
      end

      specify do
        setup_app.execute(app)

        expect(database).
          to have_received(:create)

        expect(env).
          to have_received(:[]=)

        expect(set_app_env).
          to have_received(:execute).
               with(app)
      end
    end
  end
end
