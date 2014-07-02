require 'machete/system_helper'
require 'httparty'

module Machete
  class App
    attr_reader :name, :path, :host

    def initialize path, host
      @path = path
      @name = path.split('/').last
      @host = host
    end

    def push(options = {start: true})
      command = "cf push #{name}"
      command += ' --no-start' unless options[:start]
      SystemHelper.run_cmd command
    end

    def delete
      SystemHelper.run_cmd("cf delete -f #{name}")
    end

    def set_env key, value
      SystemHelper.run_cmd("cf set-env #{name} #{key} #{value}")
    end
  end
end