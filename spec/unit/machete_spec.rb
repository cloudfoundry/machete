require 'spec_helper'
require 'machete'

describe Machete do

  describe 'deploy_app' do
    let(:app_controller) { double.as_null_object }

    before do
      allow(Machete::AppController).
          to receive(:new).
                 and_return app_controller
    end

    it 'returns the app' do
      expect(Machete.deploy_app('app_name')).to eql app_controller
    end

    it 'accepts a block' do
      expect do |block|
        Machete.deploy_app('app_name', &block)
      end.
          to yield_with_args(app_controller)
    end
  end
end