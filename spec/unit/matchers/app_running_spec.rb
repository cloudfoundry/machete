require 'spec_helper'
require 'machete/matchers'

describe '#be_running' do
  context 'app is running' do
    let(:app_controller) { Machete::AppController.new('fake_path') }

    before do
      allow(app_controller).
        to receive(:number_of_running_instances).
             and_return 0, 0, 0, 1
    end

    specify do
      expect(app_controller).to be_running
    end
  end

  context 'app is not running' do
    let(:app_controller) { Machete::AppController.new('fake_path') }

    before do
      allow(app_controller).
        to receive(:number_of_running_instances).
             and_return 0
    end

    specify 'with a timeout provided' do
      expect(app_controller).not_to be_running(0.1)
    end
  end
end
