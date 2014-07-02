require 'spec_helper'
require 'machete/matchers'

module Machete
  describe '#have_file' do
    let(:app) { App.new('app_name', nil) }
    let(:app_file) { double(:app_file) }
    let(:filename) { double(:filename) }

    before do
      allow(CF::AppFile).
        to receive(:new).
             with(app).
             and_return(app_file)

      allow(app_file).
        to receive(:has_file?).
             with(filename).
             and_return(has_file)
    end

    context 'app has file' do
      let(:has_file) { true }

      specify do
        expect(app).to have_file filename
      end
    end

    context 'app is not running' do
      let(:has_file) { false }

      specify do
        expect(app).not_to have_file filename
      end
    end
  end
end
