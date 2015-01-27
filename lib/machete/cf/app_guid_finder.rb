module Machete
  module CF
    class AppGuidFinder
      def execute(app)
        num_retries = 0

        begin
          extract_first_guid search(app.name)
        rescue
          num_retries += 1
          if num_retries < 3
            sleep(1)
            retry
          else
            raise
          end
        end
      end

      private

      def extract_first_guid(response)
        response['resources'].first['metadata']['guid']
      end

      def search(app_name)
        JSON.parse cf_response(app_name)
      end

      def cf_response(app_name)
        SystemHelper.run_cmd(find_app_command(app_name), true)
      end

      def find_app_command(app_name)
        "cf curl /v2/apps?q='name:#{app_name}'"
      end
    end
  end
end
