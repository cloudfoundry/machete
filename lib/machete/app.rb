# encoding: utf-8
module Machete
  class App
    FIXTURES_DIR = 'cf_spec/fixtures'.freeze

    attr_reader :buildpack,
                :env,
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
    end

    def src_directory
      FIXTURES_DIR + '/' + path
    end

    def needs_setup?
      env.any? || !@service.nil?
    end
  end
end
