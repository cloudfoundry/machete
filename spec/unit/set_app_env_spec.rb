require 'spec_helper'

module Machete
  module CF
    describe SetAppEnv do
      let(:app) { double(:app, name: 'app_name', env: { 'env_var' => 'env_val' }) }
      subject(:set_app_env) { SetAppEnv.new }

      before do
        allow(SystemHelper).to receive(:run_cmd).with('cf set-env app_name env_var env_val')
      end

      specify do
        set_app_env.execute(app)
        expect(SystemHelper).to have_received(:run_cmd)
      end

    end
  end
end