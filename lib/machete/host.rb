require 'machete/host/vagrant'
require 'machete/host/aws'

module Machete
  module Host
    def self.create
      vagrant_cwd = ENV['VAGRANT_CWD']

      if vagrant_cwd
        self::Vagrant.new(vagrant_cwd)
      else
        self::Aws.new
      end
    end
  end
end
