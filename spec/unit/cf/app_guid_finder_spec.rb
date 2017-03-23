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
            .to receive(:cf_curl)
            .with(curl_url)
            .and_return(JSON.parse('{
                    "total_results": 1,
                    "resources": [
                        {
                            "metadata": {
                                "guid": "' + app_guid + '"
                            }
                        }
                    ]
                }'))
        end

        context 'and a space guid in cf/config.json' do
          let(:space_guid) { '123abc' }
          before do
            allow(File)
              .to receive(:read)
              .with("#{ENV['HOME']}/.cf/config.json")
              .and_return(%Q{{"SpaceFields": {"GUID": "#{space_guid}"}}})
          end

          let(:curl_url) { "/v2/apps?q=space_guid:#{space_guid}&q=name:#{app.name}" }

          specify do
            expect(app_guid_finder.execute(app)).to eql app_guid
          end
        end

        context 'and WITHOUT a space guid in cf/config.json' do
          before do
            allow(File)
              .to receive(:read)
              .with("#{ENV['HOME']}/.cf/config.json")
              .and_raise(Errno::ENOENT.new("No such file or directory"))
          end

          let(:curl_url) { "/v2/apps?q=name:#{app.name}" }

          specify do
            expect(app_guid_finder.execute(app)).to eql app_guid
          end
        end
      end

      context 'when the response is empty' do
        it 'returns nil' do
          allow(SystemHelper).to receive(:cf_url).and_return('{}')
          expect(app_guid_finder.execute(app)).to be_nil
        end
      end
    end
  end
end
