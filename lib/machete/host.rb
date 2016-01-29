# encoding: utf-8
require 'machete/host/vagrant'

module Machete
  module Host
    def self.create
      vagrant_cwd = ENV['VAGRANT_CWD']

      self::Vagrant.new(vagrant_cwd) if vagrant_cwd
    end
  end
end
