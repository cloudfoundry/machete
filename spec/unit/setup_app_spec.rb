require 'spec_helper'

module Machete
  describe SetupApp do
    let(:database) { double(:database) }
    let(:host) { double(:host) }
    let(:app) { double(:app, host: host, name: app_name, env: env) }
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

    specify do
      setup_app.execute(app)

      expect(set_app_env).
        to have_received(:execute).
        with(app)
    end
  end
end
