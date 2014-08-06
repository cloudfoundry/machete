require 'spec_helper'

module Machete
  module CF
    describe CLI do
      describe 'an apps url' do
        let(:app) { double(
          :app,
          name: 'myApp'
        )}

        before do
          allow(SystemHelper).to receive(:run_cmd).
            with('cf app myApp').
            and_return(<<-RESPONSE)
              other stuff
              urls: the_apps_url
              other stuff
          RESPONSE
        end

        specify do
          expect(CLI.url_for_app(app)).to eql('the_apps_url')
        end
      end

    end
  end
end
