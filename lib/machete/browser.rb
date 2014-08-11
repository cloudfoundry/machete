module Machete
  class Browser
    attr_reader :app

    def initialize(app)
      @app = app
    end

    def visit_path(path)
      base_url = CF::CLI.url_for_app(app)
      @response = HTTParty.get("http://#{base_url}#{path}")
    end

    def body
      @response.body
    end

    def has_cookie_containing?(search_string)
      return false unless set_cookie_headers

      set_cookie_headers.include?(search_string)
    end

    private

    def set_cookie_headers
      @response.headers['set-cookie']
    end
  end
end
