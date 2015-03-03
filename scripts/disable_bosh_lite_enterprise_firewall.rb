#!/usr/bin/env ruby
$: << './lib'
require 'bundler/setup'
require 'machete'

Machete.logger.info '----> Enterprise firewall emulation for bosh'
Machete.logger.info '----> Disabling firewall'

Machete::Firewall.disable_firewall

