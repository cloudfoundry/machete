# encoding: utf-8
require 'spec_helper'

module Machete
  module CF
    describe AppGuidFinder do
      let(:app) { double(:app, name: 'app_name') }
      let(:app_guid) { 'app_guid' }

      subject(:app_guid_finder) { AppGuidFinder.new }

      context 'with immediate result' do
        before do
          allow(SystemHelper)
            .to receive(:run_cmd)
            .with('cf curl /v2/apps?q=\'name:' + app.name + '\'', true)
            .and_return('{
                    "total_results": 1,
                    "resources": [
                        {
                            "metadata": {
                                "guid": "' + app_guid + '"
                            }
                        }
                    ]
                }')
        end

        specify do
          expect(app_guid_finder.execute(app)).to eql app_guid
        end
      end

      context 'when the response is empty' do
        it 'returns nil' do
          allow(SystemHelper).to receive(:run_cmd).and_return('{}')
          expect(app_guid_finder.execute(app)).to be_nil
        end
      end
    end
  end
end
