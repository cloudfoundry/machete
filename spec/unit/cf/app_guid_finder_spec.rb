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
            .with(curl_cmd, true)
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

        context 'when CF_HOME is set' do
          before do
            @original_cf_home = ENV["CF_HOME"]
            ENV["CF_HOME"] = "/tmp/somwhere/else"
          end

          after do
            ENV["CF_HOME"] = @original_cf_home
          end

          context 'and a space guid in cf/config.json' do
            let(:space_guid) { '123abc' }
            before do
              expect(File)
                .to receive(:read)
                .with("#{ENV['CF_HOME']}/.cf/config.json")
                .and_return(%Q{{"SpaceFields": {"GUID": "#{space_guid}"}}})
            end

            let(:curl_cmd) { "cf curl '/v2/apps?q=space_guid:#{space_guid}&q=name:#{app.name}'" }

            specify do
              expect(app_guid_finder.execute(app)).to eql app_guid
            end
          end

          context 'and WITHOUT a space guid in cf/config.json' do
            before do
              expect(File)
                .to receive(:read)
                .with("#{ENV['CF_HOME']}/.cf/config.json")
                .and_raise(Errno::ENOENT.new("No such file or directory"))
            end

            let(:curl_cmd) { "cf curl '/v2/apps?q=name:#{app.name}'" }

            specify do
              expect(app_guid_finder.execute(app)).to eql app_guid
            end
          end
        end

        context 'when CF_HOME is not set' do
          before do
            @original_cf_home = ENV["CF_HOME"]
            ENV["CF_HOME"] = nil
          end

          after do
            ENV["CF_HOME"] = @original_cf_home
          end

          context 'and a space guid in cf/config.json' do
            let(:space_guid) { '123abc' }
            before do
              expect(File)
                .to receive(:read)
                .with("#{ENV['HOME']}/.cf/config.json")
                .and_return(%Q{{"SpaceFields": {"GUID": "#{space_guid}"}}})
            end

            let(:curl_cmd) { "cf curl '/v2/apps?q=space_guid:#{space_guid}&q=name:#{app.name}'" }

            specify do
              expect(app_guid_finder.execute(app)).to eql app_guid
            end
          end

          context 'and WITHOUT a space guid in cf/config.json' do
            before do
              expect(File)
                .to receive(:read)
                .with("#{ENV['HOME']}/.cf/config.json")
                .and_raise(Errno::ENOENT.new("No such file or directory"))
            end

            let(:curl_cmd) { "cf curl '/v2/apps?q=name:#{app.name}'" }

            specify do
              expect(app_guid_finder.execute(app)).to eql app_guid
            end
          end
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
