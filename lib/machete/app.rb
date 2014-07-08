module Machete
  class App
    FIXTURES_DIR = 'cf_spec/fixtures'

    attr_reader :name,
                :path,
                :host,
                :start_command,
                :env,
                :with_pg

    def initialize path, host, options = {}
      @path = path
      @host = host

      @name = path.split('/').last
      @start_command = options[:start_command]
      @with_pg = options[:with_pg]
      @env = options.fetch(:env, {})
    end

    def src_directory
      FIXTURES_DIR + '/' + path
    end

    def needs_setup?
      !! ( env.any? || with_pg )
    end
  end
end
