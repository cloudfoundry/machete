# encoding: utf-8
require 'spec_helper'
require 'machete/matchers'

describe '#has_logged' do
  let(:app) { Machete::App.new('app_name' ) }

  before do
    allow(app)
      .to receive(:get_logs)
      .and_return(log_contents)
  end

  context 'app has logged' do
    let(:log_contents) { 'something was logged' }

    it 'can match strings' do
      expect(app).to have_logged 'something was logged'
    end

    it 'can match regular expressions' do
      expect(app).to have_logged(/something/)
      expect(app).to_not have_logged(/something else/)
    end

    context 'special characters' do
      let(:log_contents) { 'something was logged $HERE' }

      it 'can match strings with special characters' do
        expect(app).to have_logged '$HERE'
      end
    end
  end

  context 'app has not logged' do
    let(:log_contents) { 'no droids here' }

    specify do
      expect(app).not_to have_logged 'something was logged'
    end
  end
end
