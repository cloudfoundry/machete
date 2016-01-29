# encoding: utf-8
require 'spec_helper'

module Machete
  describe Browser do
    subject(:browser) { Browser.new(app) }
    let(:app) { double(:app, name: 'app') }
    let(:response) { double(:response, content_type: content_type, code: 200) }
    let(:content_type) { nil }

    describe '#visit_path' do
      it 'makes an HTTP request to the URI' do
        expect(CF::CLI).to receive(:url_for_app).with(app).and_return('some.url')
        expect(HTTParty).to receive(:get).with('http://some.url/flub').and_return(response)

        browser.visit_path('/flub')
      end

      context 'with basic auth' do
        it 'supports username and password in the path' do
          expect(CF::CLI).to receive(:url_for_app).with(app).and_return('some.url')
          expect(HTTParty).to receive(:get).with('http://bob:sideshow@some.url/flub').and_return(response)

          browser.visit_path('/flub', username: 'bob', password: 'sideshow')
        end
      end

      context 'when an exception occurs' do
        before do
          allow(CF::CLI).to receive(:url_for_app)
          allow(browser).to receive(:sleep)
        end

        it 'retries the request ten times' do
          expect(HTTParty).to receive(:get).once.and_raise(HTTPServerError)
          expect(HTTParty).to receive(:get).exactly(9).times.and_raise(SocketError)
          expect do
            browser.visit_path('/flub')
          end.to raise_error(SocketError)
        end

        it 'returns on a successful request' do
          expect(HTTParty).to receive(:get).twice.and_raise(SocketError)
          expect(HTTParty).to receive(:get).once.and_return(response)

          browser.visit_path('/flub')
        end

        context 'when the HTTP response is 50x status code' do
          it 'raises an exception' do
            expect(HTTParty).to receive(:get).exactly(10).times.and_return(double(:bad_response, code: 500))

            expect do
              browser.visit_path('/flub')
            end.to raise_error(HTTPServerError)
          end
        end

        context 'when the HTTP response is 40x status code' do
          it 'does not raise an exception' do
            expect(HTTParty).to receive(:get).once.and_return(double(:response, code: 400))

            expect do
              browser.visit_path('/flub')
            end.to_not raise_error
          end
        end
      end
    end

    describe 'HTTP response' do
      before do
        allow(CF::CLI).to receive(:url_for_app)
        allow(HTTParty).to receive(:get).and_return(response)
      end

      describe '#body' do
        it 'returns the body of the request' do
          expect(response).to receive(:body).and_return('Hello, World')
          browser.visit_path('/test')
          expect(browser.body).to eql 'Hello, World'
        end
      end

      describe '#headers' do
        it 'returns the headers of the request' do
          expect(response).to receive(:headers).and_return('X-This-Is-A-Header' => 'true')
          browser.visit_path('/test')
          expect(browser.headers).to eql('X-This-Is-A-Header' => 'true')
        end
      end
    end

    describe '#content_type' do
      context 'when specified in the headers' do
        let(:content_type) { 'text/plain' }

        it 'returns Content-Type value' do
          allow(CF::CLI).to receive(:url_for_app)
          allow(HTTParty).to receive(:get).and_return(response)

          browser.visit_path('/')

          expect(browser.content_type).to eq 'text/plain'
        end
      end
    end

    describe '#status' do
      context 'with a successful request' do
        it 'returns 200' do
          allow(CF::CLI).to receive(:url_for_app)
          allow(HTTParty).to receive(:get).and_return(response)

          browser.visit_path('/')

          expect(browser.status).to eq 200
        end
      end
    end
  end
end
