module Machete
  module CF
    class PushApp
      def execute(app, start: true)
        SystemHelper.run_cmd push_command(app, start)
      end

      private

      def push_command(app, start)
        base_command = base_command(app)
        base_command += " -p #{app.src_directory}"

        if app.stack
          base_command += " -s #{app.stack}"
        end

        unless start
          base_command += ' --no-start'
        end

        if app.start_command
          base_command += " -c '#{app.start_command}'"
        end

        if app.buildpack
          base_command += " -b #{app.buildpack}"
        end

        return base_command
      end

      def base_command(app)
        "cf push #{app.name}"
      end
    end
  end
end
