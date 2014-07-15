require 'spec_helper'

module Machete
  module CF
    describe AppGuidFinder do
      let(:app) { double(:app, name: 'app_name') }
      let(:app_guid) { 'app_guid'}

      subject(:app_guid_finder) { AppGuidFinder.new }

      before do
        allow(SystemHelper).
          to receive(:run_cmd).
               with('cf curl /v2/apps?q=\'name:'+ app.name + '\'', true).
               and_return('{
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
  end
end
