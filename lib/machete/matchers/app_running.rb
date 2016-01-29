# encoding: utf-8
require 'rspec/matchers'

RSpec::Matchers.define :be_running do |timeout = 60|
  match do |app|
    app_status = Machete::AppStatus.new

    start_time = Time.now
    max_end_time = start_time + timeout

    while Time.now <= max_end_time
      status = app_status.execute(app)
      return false if status == Machete::AppStatus::STAGING_FAILED
      return true if status == Machete::AppStatus::RUNNING
      Kernel.sleep(1)
    end

    return false
  end

  failure_message do |app|
    app_log = Machete::CF::AppLog.new(app)
    "App is not running. Logs are:\n" +
      app_log.contents
  end
end
