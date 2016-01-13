require 'spec_helper'

module Machete::Host
  describe Vagrant::Log do
    let(:host) { double(:host) }
    subject(:host_log) { Vagrant::Log.new(host) }

    describe '#contents' do
      before do
        allow(host).to receive(:run).with('sudo cat /var/log/internet_access.log').and_return('some logging')
      end

      specify do
        expect(host_log.contents).to eql 'some logging'
      end
    end

    describe '#logged_internet_traffic?' do
      before do
        allow(host).to receive(:run)
                         .with('sudo cat /var/log/internet_access.log')
                         .and_return(result)
      end

      context 'with internet traffic' do
        let(:result) { 'cf-to-internet-traffic' }

        it 'should identify internet traffic' do
          expect(host_log.logged_internet_traffic?).to be(true)
        end
      end

      context 'without internet traffic' do
        let(:result) { 'something else' }

        it 'should find no internet traffic' do
          expect(host_log.logged_internet_traffic?).not_to be(true)
        end
      end
    end

    describe '#clear' do
      before do
        allow(host).to receive(:run)
      end

      specify do
        host_log.clear
        expect(host).to have_received(:run).with('sudo rm -f /var/log/internet_access.log')
        expect(host).to have_received(:run).with('sudo restart rsyslog')
      end
    end
  end
end
