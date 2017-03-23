# encoding: utf-8
require 'json'
require 'open3'

module Machete
  module CF
    module CLI
      class << self
        def url_for_app(app)
          app.url
        end
      end
    end
  end
end
