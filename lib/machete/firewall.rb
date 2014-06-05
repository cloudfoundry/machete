require 'machete/system_helper'

module Machete
  class FilterChain

    include Machete::SystemHelper
    extend Machete::SystemHelper

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def append(rule)
      with_vagrant_env do
        `vagrant ssh -c "sudo iptables -t filter -A #{name} #{rule} 2>&1"`
      end
    end

    def insert(position, rule)
      with_vagrant_env do
        `vagrant ssh -c "sudo iptables -t filter -I #{name} #{position} #{rule} 2>&1"`
      end
    end


    def self.create(name)
      with_vagrant_env do
        `vagrant ssh -c "sudo iptables -t filter -N #{name} 2>&1"`
      end
      self.new(name)
    end

  end


  module Firewall

    extend Machete::SystemHelper

    class << self
      def disable_firewall
        restore_iptables
      end

      def enable_firewall
        save_iptables || restore_iptables

        add_on_premises_chain
      end

      def add_on_premises_chain
        on_premises_chain = FilterChain.create('on-premises-firewall')
        on_premises_chain.append(return_on_packets_to_dns)
        on_premises_chain.append(return_on_packets_from_mac)
        on_premises_chain.append(log_all_packets)
        on_premises_chain.append(rejects_all_packets)

        warden_forward_chain = FilterChain.new('warden-forward')
        warden_forward_chain.insert(2,firewall_packets_not_destined_for_cf_machines)
      end

      def return_on_packets_to_dns
        "-d #{dns_addr} -j RETURN"
      end

      def return_on_packets_from_mac
        "-d #{mac_subnet} -j RETURN"
      end

      def log_all_packets
        '-m limit --limit 5/min -j LOG --log-prefix \"cf-to-internet-traffic: \" --log-level 0'
      end

      def rejects_all_packets
        '-j REJECT'
      end

      def firewall_packets_not_destined_for_cf_machines
        "! -d #{cf_subnet} -j on-premises-firewall"
      end

      def cf_subnet
        '10.245.0.0/19'
      end

      def mac_subnet
        '192.168.100.0/24'
      end

      def dns_addr
        @dns_addr ||= run_on_host("sudo ip -f inet addr | grep eth0 | grep inet").split(" ")[1].gsub(/\d+\/\d+$/, "0/24")
      end

      def save_iptables
        run_on_host("test -f #{iptables_file}")
        if $?.exitstatus == 0
          Machete.logger.info "Found existing #{iptables_file}"
          return false
        else
          Machete.logger.action "saving iptables to #{iptables_file}"
          run_on_host("sudo iptables-save > #{iptables_file}")
          return true
        end
      end

      def restore_iptables
        Machete.logger.action "Restoring iptables from #{iptables_file}"
        run_on_host("sudo iptables-restore #{iptables_file}")
      end

      def iptables_file
        "/tmp/machete_iptables.ipt"
      end

    end
  end
end
