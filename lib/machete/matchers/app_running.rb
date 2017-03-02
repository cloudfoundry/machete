# encoding: utf-8
require 'rspec/matchers'

RSpec::Matchers.define :be_running do |timeout = 60|
  match do |app|
    app_status = Machete::AppStatus.new

    max_end_time = Time.now + timeout

    while Time.now <= max_end_time
      status = app_status.execute(app)
      puts "------------------------------------#{status}--------------------------\n"
      return false if status == Machete::AppStatus::STAGING_FAILED
      return true if status == Machete::AppStatus::RUNNING
      Kernel.sleep(1)
    end

    return false
  end

  failure_message do |app|
    "App is not running. Logs are:\n" +
      app.get_logs
  end
end
