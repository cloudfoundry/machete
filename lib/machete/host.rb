require 'machete/host/vagrant'
require 'machete/host/aws'
require 'machete/host/unknown'

module Machete
  module Host
    def self.create
      vagrant_cwd = ENV['VAGRANT_CWD']
      bosh_target = ENV['BOSH_TARGET']

      if vagrant_cwd
        self::Vagrant.new(vagrant_cwd)
      elsif bosh_target
        self::Aws.new
      else
        self::Unknown.new
      end
    end
  end
end
