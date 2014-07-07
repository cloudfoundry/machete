module Machete
  module CF
    class PushApp
      def execute(app, start: true)
        Dir.chdir(app.src_directory) do
          SystemHelper.run_cmd push_command(app, start)
        end
      end

      private

      def push_command(app, start)
        if start
          base_command(app)
        else
          base_command(app) + ' --no-start'
        end
      end

      def base_command(app)
        "cf push #{app.name}"
      end
    end
  end
end