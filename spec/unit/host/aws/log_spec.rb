require 'spec_helper'

module Machete::Host
  describe Aws::Log do
    let(:host) { double(:host) }
    subject(:host_log) { Aws::Log.new(host) }

    describe '#contents' do
      before do
        allow(host).to receive(:run)
          .with('echo p | sudo -S cat /var/log/messages', :runner_z1)
          .and_return('some logging', :runner_z1)
      end

      specify do
        expect(host_log.contents).to eql 'some logging'
      end
    end

    describe '#logged_internet_traffic?' do
      before do
        allow(host).to receive(:run)
                         .with('echo p | sudo -S cat /var/log/messages', :runner_z1)
                         .and_return(result)
      end

      context 'with internet traffic' do
        let(:result) { 'OUT=eth0' }

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
        expect(host).to have_received(:run).with([
                                                   "echo p | sudo -S rm /var/log/messages",
                                                   "echo p | sudo -S restart rsyslog"
                                                 ], :runner_z1)
      end
    end
  end
end
