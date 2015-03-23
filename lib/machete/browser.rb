module Machete
  class Browser
    attr_reader :app

    def initialize(app)
      @app = app
    end

    def visit_path(path)
      retries = 1
      begin
        base_url = CF::CLI.url_for_app(app)
        @response = HTTParty.get("http://#{base_url}#{path}")
      rescue SocketError
        raise if retries == 3
        retries += 1
        sleep(0.5)
        retry
      end
    end

    def body
      @response.body
    end

    def contains_cookie?(search_string)
      return false unless set_cookie_headers

      set_cookie_headers.include?(search_string)
    end

    private

    def set_cookie_headers
      @response.headers['set-cookie']
    end
  end
end
