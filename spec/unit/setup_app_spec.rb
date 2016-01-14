require 'spec_helper'

module Machete
  describe SetupApp do
    let(:app) { double(:app, name: 'app_name', env: { 'env_var' => 'env_val' }) }

    before do
      allow(SystemHelper).to receive(:run_cmd)
    end

    it 'setups environment variables' do
      expect(SystemHelper).to receive(:run_cmd).with('cf set-env app_name env_var env_val')
      SetupApp.new.execute(app)
    end

    it 'setups a fake service for the app' do
      expect(SystemHelper).to receive(:run_cmd).with("cf cups app_name-test-service -p '{\"username\":\"AdM1n\",\"password\":\"pa55woRD\"}'")
      SetupApp.new.execute(app)
    end
  end
end
