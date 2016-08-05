# encoding: utf-8
require 'machete/system_helper'
require 'childprocess'

module Machete
  module CF
    module AppLogs
      attr_reader :app_name
      attr_reader :push_logs

      def setup_logs(app_name)
        @app_name = app_name
      end

      def start_logs
        @log_output_file = Tempfile.new("log-output-for-#{app_name}")
        @log_process = ChildProcess.build("cf", "logs", app_name)
        @log_process.io.stdout = @log_output_file
        @log_process.start
      end

      def record_push_logs(logs)
        @push_logs = logs
      end

      def end_logs
        @log_process.stop if defined? @log_process
      end

      def get_logs
        push_logs + File.read(@log_output_file)
      end

      def get_recent_logs
        SystemHelper.run_cmd("cf logs --recent #{app_name}")
      end
    end
  end
end
