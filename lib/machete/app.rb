require 'machete/system_helper'
require 'httparty'

module Machete
  class App
    include SystemHelper

    attr_reader :app_name

    def initialize app_name
      @app_name = app_name
    end

    def push(options = {start: true})
      command = "cf push #{app_name}"
      command += " --no-start" unless options[:start]
      run_cmd command
    end

    def delete
      run_cmd("cf delete -f #{app_name}")
    end

    def homepage_body
      HTTParty.get("http://#{url}").body
    end

    private

    def url
      run_cmd("cf app #{app_name} | grep url").split(' ').last
    end
  end
end