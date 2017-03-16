# encoding: utf-8
module Machete
  module CF
    class PushApp
      def execute(app, start: true)
        logs = SystemHelper.run_cmd push_command(app, start)
        app.start_logs
        app.record_push_logs(logs)
      end

      private

      def push_command(app, start)
        base_command = base_command(app)
        base_command += " -p #{app.src_directory}"

        manifest_file = File.join(app.src_directory, 'manifest.yml')

        if app.manifest
          manifest = app.manifest
        elsif File.exist?(manifest_file)
          manifest = manifest_file
        else
          manifest = nil
        end

        base_command += " -f #{manifest}" if manifest

        base_command += " -s #{app.stack}" if app.stack

        base_command += ' --no-start' unless start

        base_command += " -c '#{app.start_command}'" if app.start_command

        base_command += " -b #{app.buildpack}" if app.buildpack

        base_command
      end

      def base_command(app)
        "cf push --random-route #{app.name}"
      end
    end
  end
end
