require 'spec_helper'

module Machete
  describe Browser do

    subject(:browser) { Browser.new(app) }
    let(:app) { double(:app, name: 'app') }
    let(:response) { double(:response, headers: headers, code: 200) }
    let(:headers) { {} }

    describe '#visit_path' do
      it 'makes an HTTP request to the URI' do
        expect(CF::CLI).to receive(:url_for_app).with(app).and_return('some.url')
        expect(HTTParty).to receive(:get).with('http://some.url/flub').and_return(response)

        browser.visit_path('/flub')
      end

      context 'when an exception occurs' do
        before do
          allow(CF::CLI).to receive(:url_for_app)
          allow(browser).to receive(:sleep)
        end

        it 'retries the request three times' do
          expect(HTTParty).to receive(:get).once.and_raise(HTTPStatusCodeError)
          expect(HTTParty).to receive(:get).exactly(2).times.and_raise(SocketError)
          expect {
            browser.visit_path('/flub')
          }.to raise_error(SocketError)
        end

        it 'returns on a successful request' do
          expect(HTTParty).to receive(:get).twice.and_raise(SocketError)
          expect(HTTParty).to receive(:get).once.and_return(response)

          browser.visit_path('/flub')
        end

        context 'when the HTTP response is not 200 OK' do
          it 'raises an exception' do
            expect(HTTParty).to receive(:get).exactly(3).times.and_return(double(:bad_response, code: 500))

            expect {
              browser.visit_path('/flub')
            }.to raise_error(HTTPStatusCodeError)
          end
        end
      end
    end

    describe '#body' do
      before do
        allow(CF::CLI).to receive(:url_for_app)
        allow(HTTParty).to receive(:get).and_return(response)
      end

      it 'returns the body of the request' do
        expect(response).to receive(:body).and_return('Hello, World')
        browser.visit_path('/test')
        expect(browser.body).to eql 'Hello, World'
      end
    end

    describe 'contains_cookie?' do
      before do
        allow(CF::CLI).to receive(:url_for_app)
        allow(HTTParty).to receive(:get).and_return(response)

        browser.visit_path('unimportant')
      end

      context "a cookie string is not set" do
        it "does not find any cookie string" do
          expect(browser.contains_cookie?("my-cookie-string")).to eql false
        end
      end

      context "a cookie string is set" do
        before do
          headers["set-cookie"] = 'this has my-cookie-string in it someplace'
        end

        specify "and 'my-cookie-string' is in the set-cookie header" do
          expect(browser.contains_cookie?("my-cookie-string")).to eql true
        end

        specify "and 'not-my-cookie-string' is not in the set-cookie header" do
          expect(browser.contains_cookie?("not-my-cookie-string")).to eql false
        end
      end
    end
  end
end
