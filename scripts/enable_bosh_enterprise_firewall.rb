#!/usr/bin/env ruby
$: << './lib'
require 'bundler/setup'
require 'machete'

Machete.logger.info '----> Enterprise firewall emulation for bosh'
Machete.logger.info '----> Enabling firewall'

Machete::Firewall.enable_firewall
Machete::Firewall.filter_internet_traffic_to_file('/var/log/internet_access.log')

