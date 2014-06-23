require './spec/spec_helper'
require 'machete/app'

describe Machete::App do
  subject(:app) { Machete::App.new('kyle_has_an_awesome_app') }

  describe '#push' do
    before do
      allow(app).to receive(:run_cmd)
    end

    context 'starting the app immediately' do
      before do
        app.push
      end

      specify do
        expect(app).to have_received(:run_cmd).with('cf push kyle_has_an_awesome_app')
      end
    end

    context 'not starting the app immediately' do
      before do
        app.push(start: false)
      end

      specify do
        expect(app).to have_received(:run_cmd).with('cf push kyle_has_an_awesome_app --no-start')
      end
    end
  end

  describe '#delete' do

  end
end