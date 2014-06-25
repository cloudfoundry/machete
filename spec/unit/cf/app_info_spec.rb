require 'spec_helper'

module Machete
  module CF
    describe AppInfo do
      let(:app) { double(:app, name: 'app_name') }
      subject(:app_info) { AppInfo.new(app) }

      describe '#instance_count' do
        let(:app_resource_url) { '/v2/apps/app_url' }

        before do
          allow(SystemHelper).
            to receive(:run_cmd).
                 with('cf curl /v2/apps?q=\'name:app_name\'', true).
                 and_return('{
                  "total_results": 1,
                  "resources": [
                      {
                          "metadata": {
                              "url": "' + app_resource_url + '"
                          }
                      }
                  ]
              }')

          allow(SystemHelper).
            to receive(:run_cmd).
                 with('cf curl ' + app_resource_url + '/summary', true).
                 and_return('{"running_instances":3}')
        end

        specify do
          expect(app_info.instance_count).to eql 3
        end
      end
    end
  end
end