require 'machete/system_helper'
require 'httparty'

module Machete
  class App
    attr_reader :name, :path, :host, :start_command

    def initialize path, host, options = {}
      @path = path
      @name = path.split('/').last
      @host = host
      @start_command = options[:start_command]
    end

    def push(options = {start: true})
      command = "cf push #{name}"
      command += ' --no-start' unless options[:start]
      command += " -c '#{start_command}'" if start_command
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