require 'spec_helper'

module Machete
  describe Host::Log do
    let(:host) { double(:host) }
    subject(:host_log) { Host::Log.new(host) }

    describe '#contents' do
      before do
        allow(host).to receive(:run).with('sudo cat /var/log/internet_access.log').and_return('some logging')
      end

      specify do
        expect(host_log.contents).to eql 'some logging'
      end
    end

    describe '#clear' do
      before do
        allow(host).to receive(:run)
      end

      specify do
        host_log.clear
        expect(host).to have_received(:run).with('sudo rm /var/log/internet_access.log')
        expect(host).to have_received(:run).with('sudo restart rsyslog')
      end
    end
  end
end