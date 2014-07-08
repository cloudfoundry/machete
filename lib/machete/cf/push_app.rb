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
        unless start
          return base_command(app) + ' --no-start'
        end

        if app.start_command
          return base_command(app) + " -c '#{app.start_command}'"
        end

        base_command(app)
      end

      def base_command(app)
        "cf push #{app.name}"
      end
    end
  end
end
