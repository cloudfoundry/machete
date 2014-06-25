require 'spec_helper'
require 'machete/matchers'

describe '#be_running' do
  let(:app_info) { double(:app_info) }
  let(:app) { Machete::App.new('app_name', nil) }

  before do
    allow(Machete::CF::AppInfo).
      to receive(:new).
           with(app).
           and_return(app_info)

    allow(app_info).
      to receive(:instance_count).
           and_return(instance_count)
  end

  context 'app is running' do
    let(:instance_count) { 1 }

    before do
      allow(app_info).
        to receive(:instance_count).
             and_return 0, 0, 0, instance_count
    end

    specify do
      expect(app).to be_running
    end
  end

  context 'app is not running' do
    let(:instance_count) { 0 }

    before do
      allow(app_info).
        to receive(:instance_count).
             and_return instance_count
    end

    specify 'with a timeout provided' do
      expect(app).not_to be_running(0.1)
    end
  end
end
