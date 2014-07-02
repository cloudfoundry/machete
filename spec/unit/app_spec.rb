require 'spec_helper'

module Machete
  describe App do
    let(:host) { double(:host) }
    subject(:app) { App.new('path/to/example_app', host) }

    before do
      allow(SystemHelper).to receive(:run_cmd)
    end

    describe '#push' do
      context 'starting the app immediately' do
        before do
          app.push
        end

        specify do
          expect(SystemHelper).to have_received(:run_cmd).with('cf push example_app')
        end
      end

      context 'not starting the app immediately' do
        before do
          app.push(start: false)
        end

        specify do
          expect(SystemHelper).to have_received(:run_cmd).with('cf push example_app --no-start')
        end
      end
    end

    describe '#delete' do
      before do
        app.delete
      end

      specify do
        expect(SystemHelper).to have_received(:run_cmd).with('cf delete -f example_app')
      end
    end

    describe '#homepage_body' do
      let(:website) { double(body: 'kyles homepage body') }

      before do
        allow(SystemHelper).to receive(:run_cmd).with('cf app example_app | grep url').and_return('urls: www.kylesurl.com')
        allow(HTTParty).to receive(:get).with('http://www.kylesurl.com').and_return website
      end

      specify do
        expect(app.homepage_body).to eql 'kyles homepage body'
      end
    end

    describe '#set_env' do
      before do
        app.set_env('env_var', 'env_val')
      end

      specify do
        expect(SystemHelper).to have_received(:run_cmd).with('cf set-env example_app env_var env_val')
      end
    end
  end
end