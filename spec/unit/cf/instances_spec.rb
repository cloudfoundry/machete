require 'spec_helper'

module Machete
  module CF
    describe Instances do
      let(:app_guid_finder) { double(:app_guid_finder) }
      let(:app) { double(:app) }
      let(:app_guid) { 'app_guid' }
      let(:instances_json) { double(:instances_json) }

      subject(:instances_command) { Instances.new(app) }

      before do
        allow(AppGuidFinder).
          to receive(:new).
               and_return(app_guid_finder)

        allow(app_guid_finder).
          to receive(:execute).
               with(app).
               and_return(app_guid)

        allow(SystemHelper).
          to receive(:run_cmd).
               with("cf curl /v2/apps/#{app_guid}/instances").
               and_return(instances_json)

        allow(JSON).
          to receive(:parse).
               with(instances_json).
               and_return(cf_response)
      end

      context 'had an error' do
        let(:cf_response) do
          {
            'code' => 170004,
            'description' => 'App staging failed in the buildpack compile phase',
            'error_code' => 'CF-ErrorCode'
          }
        end

        specify do
          instances = instances_command.execute
          expect(instances).to eql []
          expect(instances_command.error).to eql 'CF-ErrorCode'
        end
      end

      context 'no error' do
        let(:cf_response) do
          {
            '0' => {
              'state' => 'RUNNING'
            }
          }
        end
        specify do
          instances = instances_command.execute
          expect(instances.size).to eql 1
          expect(instances.first.state).to eql 'RUNNING'
          expect(instances_command.error).to be_nil
        end
      end
    end
  end
end
