# encoding: utf-8
require 'spec_helper'
require 'machete/matchers'

describe '#be_running' do
  let(:app) { Machete::App.new('app_name') }
  let(:app_status) { double(:app_status) }

  before do
    allow(Machete::AppStatus)
      .to receive(:new)
      .and_return(app_status)
  end

  context 'app is running' do
    before do
      allow(app_status)
        .to receive(:execute)
        .with(app)
        .and_return(
          Machete::AppStatus::UNKNOWN,
          Machete::AppStatus::RUNNING
        )
    end

    specify do
      expect(app).to be_running
    end
  end

  context 'app has failed' do
    before do
      allow(app_status)
        .to receive(:execute)
        .with(app)
        .and_return(
          Machete::AppStatus::UNKNOWN,
          Machete::AppStatus::STAGING_FAILED
        )
    end

    specify do
      expect(app).not_to be_running
    end
  end
end
