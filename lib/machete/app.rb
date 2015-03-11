module Machete
  class App
    FIXTURES_DIR = 'cf_spec/fixtures'

    attr_reader :buildpack,
                :env,
                :host,
                :name,
                :path,
                :stack,
                :start_command,
                :with_pg

    def initialize path, host, options = {}
      @path = path
      @host = host

      @name = path.split('/').last
      @start_command = options[:start_command]
      @with_pg = options[:with_pg]
      @env = options.fetch(:env, {})
      @stack = options[:stack] || ENV['CF_STACK']
      @buildpack = options[:buildpack]
    end

    def src_directory
      FIXTURES_DIR + '/' + path
    end

    def needs_setup?
      !! ( env.any? || with_pg )
    end
  end
end
