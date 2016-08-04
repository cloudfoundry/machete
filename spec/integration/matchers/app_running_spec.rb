# encoding: utf-8
require 'spec_helper'

describe '#be_running' do
  before { Timecop.scale(3600) }
  after  { Timecop.return }

  context 'When the app has not deployed immediately' do
    context 'And it never starts' do
      it 'is not running' do
        expect(Machete::SystemHelper).to receive(:run_cmd)
          .with("cf curl /v2/apps?q='name:fake_app'", true)
          .at_least(:twice)
          .and_return('{"resources":[]}')

        app = Machete::App.new('fake_app')
        expect(app).to_not be_running
      end
    end

    context 'And it starts after awhile' do
      it 'starts running' do
        expect(Machete::SystemHelper).to receive(:run_cmd)
          .with("cf curl /v2/apps?q='name:fake_app'", true)
          .at_least(:twice)
          .and_return('{"resources":[]}', {
            resources: [
              metadata: {
                guid: 'awesome-guid'
              }
            ]
          }.to_json)

        expect(Machete::SystemHelper).to receive(:run_cmd)
          .with('cf curl /v2/apps/awesome-guid/instances')
          .at_least(:once)
          .and_return({
            '0' => {
              state: 'RUNNING'
            }
          }.to_json)

        expect(Kernel).to receive(:sleep)

        app = Machete::App.new('fake_app')
        expect(app).to be_running
      end
    end
  end
end
