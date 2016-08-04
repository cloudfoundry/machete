# encoding: utf-8
module Machete
  module CF
    class DeleteApp
      def execute(app)
        app.end_logs
        SystemHelper.run_cmd("cf delete -f -r #{app.name}")
      end
    end
  end
end
