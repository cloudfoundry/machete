# encoding: utf-8
module Machete
  module CF
    class RestartApp
      def execute(app)
        SystemHelper.run_cmd("cf restart #{app.name}")
      end
    end
  end
end
