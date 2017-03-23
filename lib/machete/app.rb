# encoding: utf-8
module Machete
  class App
    include CF::AppLogs

    FIXTURES_DIR = 'cf_spec/fixtures'.freeze

    attr_reader :buildpack,
                :env,
                :manifest,
                :name,
                :path,
                :stack,
                :start_command

    def initialize(path, options = {})
      @path = path

      @name = options[:name] || path.split('/').last
      @start_command = options[:start_command]
      @env = options.fetch(:env, {})
      @stack = options[:stack] || ENV['CF_STACK']
      @buildpack = options[:buildpack]
      @service = options[:service]
      @manifest = options[:manifest]
      setup_logs(name)
    end

    def src_directory
      FIXTURES_DIR + '/' + path
    end

    def needs_setup?
      env.any? || !@service.nil?
    end

    def guid
      @guid ||= Machete::CF::AppGuidFinder.new.execute(self)
    end

    def url
      return @url if @url
      data = curl("/v2/apps/#{guid}/routes")
      host = data.dig('resources', 0, 'entity', 'host')
      raise "Could not find url for #{name}" unless host
      data = curl(data.dig('resources', 0, 'entity', 'domain_url'))
      domain = data.dig('entity', 'name')
      raise "Could not find url for #{name}" unless domain
      @url = "#{host}.#{domain}"
    end
  end
end
