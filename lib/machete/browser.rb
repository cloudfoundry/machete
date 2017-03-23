# encoding: utf-8
module Machete
  HTTPServerError = Class.new(RuntimeError)

  class Browser
    attr_reader :app

    def initialize(app)
      @app = app
    end

    def visit_path(path, username: nil, password: nil, allow_404: false)
      retries = 1
      begin
        @response = if username.nil? && password.nil?
                      HTTParty.get("http://#{base_url}#{path}")
                    else
                      HTTParty.get("http://#{username}:#{password}@#{base_url}#{path}")
        end

        fail HTTPServerError.new("responded with error code #{@response.code}") if (@response.code >= 400 && !allow_404) || @response.code >= 500
      rescue SocketError, HTTPServerError
        raise if retries == 10
        retries += 1
        sleep(0.5)
        retry
      end
    end

    def base_url
      @base_url ||= CF::CLI.url_for_app(app)
    end

    def body
      @response.body
    end

    def headers
      @response.headers
    end

    def status
      @response.code
    end

    def content_type
      @response.content_type
    end
  end
end
