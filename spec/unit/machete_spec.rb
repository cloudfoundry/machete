require 'spec_helper'

describe Machete do

  describe 'deploy_app' do
    subject(:app) { Machete.deploy_app('path/to/app_name') }

    let(:path){'path/to/app_name'}
    let(:app_controller) { double(:app_controller) }
    let(:host) { double(:host) }

    before do
      allow(Machete::AppController).
        to receive(:new).
             and_return app_controller

      allow(Machete::Host).
        to receive(:new).
        and_return(host)

      allow(app_controller).
        to receive(:push)
    end

    it 'returns the app' do
      expect(app.name).to eql 'app_name'
      expect(app.host).to eql host
      expect(app.path).to eql path
    end

    it 'pushes the app' do
      app
      expect(app_controller).to have_received(:push)
    end
  end
end