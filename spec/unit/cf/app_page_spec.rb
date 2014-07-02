require 'spec_helper'

module Machete
  module CF
    describe AppPage do
      let(:app) { double(:app, name: 'app_name') }
      subject(:app_page) { AppPage.new(app) }

      describe '#body' do
        let(:website) { double(body: 'homepage body') }

        before do
          allow(SystemHelper).to receive(:run_cmd).with('cf app app_name | grep url').and_return('urls: www.myurl.com')
          allow(HTTParty).to receive(:get).with('http://www.myurl.com').and_return website
        end

        specify do
          expect(app_page.body).to eql 'homepage body'
          expect(SystemHelper).to have_received(:run_cmd).with('cf app app_name | grep url')
        end
      end
    end
  end
end