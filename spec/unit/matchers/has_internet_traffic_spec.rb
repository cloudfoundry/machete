require 'spec_helper'
require 'machete/matchers'

module Machete
  describe '#has_internet_traffic' do
    let(:app)  { double(:app, host: host) }
    let(:host) { double(:host) }
    let(:host_log) { double(:host_log)}

    before do

      allow(Host::Log).
        to receive(:new).
        with(host).
        and_return(host_log)

      allow(host_log).
        to receive(:contents).
        and_return(log_contents)
    end

    context 'vagrant has internet traffic ' do
      let(:log_contents) { 'cf-to-internet-traffic' }

      specify do
        expect(app.host).to have_internet_traffic
      end
    end

    context 'vagrant does not have internet traffic' do
      let(:log_contents) { '' }

      specify do
        expect(app.host).not_to have_internet_traffic
      end
    end
  end
end