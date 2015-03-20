module Machete
  module CF
    module CLI
      CF_URL_REGEX  = /^\s*urls:\s*(.*)/

      class << self
        def url_for_app(app)
          cf_app_result = SystemHelper.run_cmd("cf app #{app.name}")

          if match = cf_app_result.match(CF_URL_REGEX)
            match[1]
          else
            raise <<-ERROR.chomp
Failed finding app URL
response:

#{cf_app_result}
ERROR
          end
        end
      end
    end
  end
end
