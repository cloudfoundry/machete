require 'machete/host/vagrant'

module Machete
  module Host
    def self.create
      vagrant_cwd = ENV['VAGRANT_CWD']

      if vagrant_cwd
        self::Vagrant.new(vagrant_cwd)
      end
    end
  end
end
