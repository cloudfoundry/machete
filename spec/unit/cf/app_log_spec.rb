# encoding: utf-8
require 'spec_helper'

module Machete
  module CF
    describe AppLog do
      let(:app_name) { 'AppName' }
      let(:app) { double(:app, name: app_name) }
      subject(:app_log) { AppLog.new(app) }

      describe '#contents' do
        before do
          allow(Machete.logger).to receive(:info)
          allow(SystemHelper).to receive(:run_cmd).with("cf logs #{app_name} --recent").and_return('some logging')
        end

        specify do
          expect(app_log.contents).to eql 'some logging'
        end
      end
    end
  end
end
