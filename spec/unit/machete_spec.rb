require 'spec_helper'

describe Machete do

  describe '.deploy_app' do
    let(:app) { double(:app) }
    let(:path) { 'path/to/app_name' }
    let(:app_controller) { double(:app_controller) }
    let(:host) { double(:host) }
    let(:app_controller_options) { {} }

    before do
      allow(Machete::AppController).
        to receive(:new).
             with(no_args).
             and_return app_controller

      allow(Machete::Host).
        to receive(:new).
             and_return(host)

      allow(app_controller).
        to receive(:deploy).
             with(app, app_controller_options)
    end

    context 'no additional options' do
      before do
        allow(Machete::App).
          to receive(:new).
               with(path, host, start_command: nil).
               and_return(app)
      end

      specify do
        result = Machete.deploy_app('path/to/app_name')
        expect(result).to eql app
        expect(app_controller).to have_received(:deploy)

      end
    end

    context 'with additional options' do
      context 'with start command' do
        let(:start_command) { double(:start_command) }

        before do
          allow(Machete::App).
            to receive(:new).
                 with(path, host, start_command: start_command).
                 and_return(app)
        end

        specify do
          result = Machete.deploy_app('path/to/app_name', start_command: start_command)
          expect(result).to eql app
          expect(app_controller).to have_received(:deploy)
        end
      end
    end
  end
end