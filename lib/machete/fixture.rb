require 'machete/system_helper'
require 'machete/logger'

module Machete
  class Fixture
    include SystemHelper

    attr_reader :app_path

    def initialize app_path
      @app_path = app_path
    end

    def directory
      "cf_spec/fixtures/#{app_path}"
    end

    def vendor
      if File.exists?('package.sh')
        Machete.logger.action('Vendoring dependencies before push')
        Bundler.with_clean_env do
          run_cmd('./package.sh')
        end
      end
    end
  end
end