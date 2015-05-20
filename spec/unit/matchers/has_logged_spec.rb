require 'spec_helper'
require 'machete/matchers'

describe '#has_logged' do
  let(:app_log) { double(:app_log) }
  let(:host) { double(:host) }
  let(:app) { Machete::App.new('app_name', host) }

  before do
    allow(Machete::CF::AppLog).
      to receive(:new).
           with(app).
           and_return(app_log)

    allow(app_log).
      to receive(:contents).
           and_return(log_contents)
  end

  context 'app has logged' do
    let(:log_contents) { 'something was logged' }

    it 'can match strings' do
      expect(app).to have_logged 'something was logged'
    end

    it 'can match regular expressions' do
      expect(app).to have_logged /something/
      expect(app).to_not have_logged /something else/
    end
  end

  context 'app has not logged' do
    let(:log_contents) { 'no droids here' }

    specify do
      expect(app).not_to have_logged 'something was logged'
    end
  end
end
