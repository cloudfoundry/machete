module Machete
  module CF
    module CLI
      CF_URL_REGEX = /^\s*urls:\s*(.*)/

      class << self
        def url_for_app(app)
          cf_app_result = SystemHelper.run_cmd("cf app #{app.name}")

          cf_app_result.match(CF_URL_REGEX)[1]
        end
      end
    end
  end
end
