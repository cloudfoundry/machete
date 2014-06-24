require 'spec_helper'

describe Machete::Firewall do
  subject(:firewall) { Machete::Firewall }

  describe "filter_internet_traffic_to_file" do
    before do
      allow(Machete).to receive(:logger).and_return(double.as_null_object)

      @host_commands = []
      allow_any_instance_of(Machete::SystemHelper).to receive(:run_on_host) do |_, command|
        @host_commands.push command
        ""
      end
    end

    specify do
      firewall.filter_internet_traffic_to_file('/target_file/path/log.log')

      expect(@host_commands.first).to match("echo :msg,contains,\'cf-to-internet-traffic: \' /target_file/path/log.log | sudo tee /etc/rsyslog.d/10-cf-internet.conf")
      expect(@host_commands.last).to match("sudo restart rsyslog")
    end

  end
end
