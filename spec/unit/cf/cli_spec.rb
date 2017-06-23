# encoding: utf-8
require 'spec_helper'

module Machete
  module CF
    describe CLI do
      let(:app) do
        double(
          :app,
          name: 'myApp'
        )
      end
      context 'an app has a URL' do
        specify do
          expect(SystemHelper).to receive(:run_cmd)
            .with('cf app myApp')
            .and_return(<<-RESPONSE)
              other stuff
              urls: the_apps_url
              other stuff
          RESPONSE

          expect(CLI.url_for_app(app)).to eql('the_apps_url')
        end

        context 'new cf cli' do
          specify do
            expect(SystemHelper).to receive(:run_cmd)
              .with('cf app myApp')
              .and_return(<<-RESPONSE)
              other stuff
              routes: some.excitement.com
              other stuff
            RESPONSE

            expect(CLI.url_for_app(app)).to eql('some.excitement.com')
          end
        end
      end

      context 'when the app does not have a URL' do
        specify do
          expect(SystemHelper).to receive(:run_cmd)
            .with('cf app myApp')
            .and_return('this is not the response you are looking for')

          expect do
            CLI.url_for_app(app)
          end.to raise_error("Failed finding app URL\nresponse:\n\nthis is not the response you are looking for")
        end
      end
    end
  end
end
