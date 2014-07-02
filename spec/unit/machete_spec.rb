require 'spec_helper'

describe Machete do

  describe 'deploy_app' do
    let(:path) { 'path/to/app_name' }
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
        to receive(:push).
             with(no_args)
    end

    context 'no additional options' do
      specify do
        app = Machete.deploy_app('path/to/app_name')
        expect(app.name).to eql 'app_name'
        expect(app.host).to eql host
        expect(app.path).to eql path

        expect(app_controller).to have_received(:push)

      end
    end

    context 'with additional options' do
      context 'with start command' do
        let(:start_command) { double(:start_command) }

        specify do
          app = Machete.deploy_app('path/to/app_name', start_command: start_command)
          expect(app.start_command).to eql start_command
        end
      end
    end
  end
end