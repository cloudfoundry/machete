# encoding: utf-8
require 'bundler'

module Machete
  module Host
    class VagrantCWDMissingError < StandardError
    end

    class Vagrant
      def initialize(vagrant_cwd)
        @vagrant_cwd = vagrant_cwd
      end

      def run(command)
        check_vagrant_cwd

        result = ''
        Bundler.with_clean_env do
          result = SystemHelper.run_cmd "vagrant ssh -c '#{command}' 2>&1"
        end
        result
      end

      private

      def check_vagrant_cwd
        fail VagrantCWDMissingError, 'VAGRANT_CWD environment variable is not set' unless @vagrant_cwd
      end
    end
  end
end
