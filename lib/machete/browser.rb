module Machete
  class Browser
    attr_reader :app,
                :body

    def initialize(app)
      @app = app
    end

    def visit_path(path)
      base_url = CF::CLI.url_for_app(app)
      @body = HTTParty.get("http://#{base_url}#{path}").body
    end
  end
end
