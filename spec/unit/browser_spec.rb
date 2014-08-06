require 'spec_helper'

module Machete
  describe Browser do

    subject(:browser) { Browser.new(app) }
    let(:app) { double(:app) }
    let(:response) { double(:response) }

    before do
      allow(HTTParty).to receive(:get).
                           and_return(response)

      allow(response).to receive(:body).
                           and_return('<html><body>Hello, Test!</body></html>')

      allow(CF::CLI).to receive(:url_for_app).
                          with(app).
                          and_return("some.url")
    end

    describe 'visiting the app url and path' do
      specify do
        browser.visit_path('/flub')
        expect(HTTParty).to have_received(:get).
                              with("http://some.url/flub")
      end
    end

    describe 'examining the body of the browser' do
      specify do
        browser.visit_path('/test')
        expect(browser.body).to eql '<html><body>Hello, Test!</body></html>'
      end
    end
  end
end
