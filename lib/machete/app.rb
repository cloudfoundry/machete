module Machete
  class App
    FIXTURES_DIR = 'cf_spec/fixtures'

    attr_reader :buildpack,
                :env,
                :host,
                :name,
                :path,
                :stack,
                :start_command

    def initialize path, host, options = {}
      @path = path
      @host = host

      @name = options[:name] || path.split('/').last
      @start_command = options[:start_command]
      @env = options.fetch(:env, {})
      @stack = options[:stack] || ENV['CF_STACK']
      @buildpack = options[:buildpack]
    end

    def src_directory
      FIXTURES_DIR + '/' + path
    end

    def needs_setup?
      !! ( env.any?  )
    end
  end
end
