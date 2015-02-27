require 'spec_helper'
require 'machete/matchers'

module Machete
  describe '#has_internet_traffic' do
    let(:app)  { double(:app, host: host) }
    let(:host) { double(:host) }
    let(:log_manager) { double(:log_manager) }

    before do

      allow(host).
        to receive(:create_log_manager).
        and_return(log_manager)

      allow(log_manager).
        to receive(:logged_internet_traffic?).
        and_return(had_traffic)
    end

    context 'there is internet traffic ' do
      let(:had_traffic) { true }

      specify do
        expect(app.host).to have_internet_traffic
      end
    end

    context 'there is not internet traffic' do
      let(:had_traffic) { false }

      specify do
        expect(app.host).not_to have_internet_traffic
      end
    end
  end
end
