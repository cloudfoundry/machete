module Machete
  HTTPServerError = Class.new(RuntimeError)

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

        raise HTTPServerError.new("responded with error code #{@response.code}") if @response.code >= 500
      rescue SocketError, HTTPServerError
        raise if retries == 10
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
