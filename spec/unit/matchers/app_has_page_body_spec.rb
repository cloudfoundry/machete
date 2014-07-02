require 'spec_helper'
require 'machete/matchers'

module Machete
  describe '#have_page_body' do
    let(:app) { App.new('app_name', nil) }
    let(:app_page) { double(:app_page) }
    let(:body_text) { double(:body_text) }

    before do
      allow(CF::AppPage).
        to receive(:new).
             with(app).
             and_return(app_page)

      allow(app_page).
        to receive(:body).
             and_return(body_text)
    end

    context 'app has body text' do
      let(:body_text) { 'containing' }

      specify do
        expect(app).to have_page_body 'contain'
      end
    end

    context 'app does not have body text' do
      let(:body_text) { 'nothing interesting' }

      specify do
        expect(app).not_to have_page_body 'contain'
      end
    end
  end
end
