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