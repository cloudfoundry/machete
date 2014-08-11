require 'spec_helper'

module Machete
  describe Browser do

    subject(:browser) { Browser.new(app) }
    let(:app) { double(:app) }
    let(:response) { double(:response, headers: headers) }
    let(:headers) { {} }

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

    describe 'finding string in set-cookie headers' do
      before do
        allow(HTTParty).to receive(:get).
                              and_return(response)

        browser.visit_path('unimportant')
      end

      context "a cookie string is not set" do
        specify "should not find any cookie string" do
          expect(browser.has_cookie_containing?("my-cookie-string")).to eql false
        end
      end

      context "a cookie string is set" do
        before do
          headers["set-cookie"] = 'this has my-cookie-string in it someplace'
        end

        specify "and 'my-cookie-string' is in the set-cookie header" do
          expect(browser.has_cookie_containing?("my-cookie-string")).to eql true
        end

        specify "and 'not-my-cookie-string' is not in the set-cookie header" do
          expect(browser.has_cookie_containing?("not-my-cookie-string")).to eql false
        end
      end
    end
  end
end
