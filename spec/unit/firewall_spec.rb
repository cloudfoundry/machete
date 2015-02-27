require 'spec_helper'

module Machete
  describe Firewall do
    subject(:firewall) { Firewall }

    describe 'filter_internet_traffic_to_file' do
      let(:host) { double(:host, run: true) }

      before do
        allow(Machete).to receive(:logger).and_return(double.as_null_object)
        allow(Host::Vagrant).to receive(:new).and_return(host)
      end

      specify do
        firewall.filter_internet_traffic_to_file('/target_file/path/log.log')

        expect(host).
          to have_received(:run).
               with("echo :msg,contains,\\\"cf-to-internet-traffic: \\\" /target_file/path/log.log | sudo tee /etc/rsyslog.d/10-cf-internet.conf").ordered

        expect(host).
          to have_received(:run).
               with("sudo restart rsyslog").ordered
      end
    end
  end
end
