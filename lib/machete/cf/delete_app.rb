module Machete
  module CF
    class DeleteApp
      def execute(app)
        SystemHelper.run_cmd("cf delete -f -r #{app.name}")
      end
    end
  end
end
