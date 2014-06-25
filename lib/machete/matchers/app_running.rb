require 'rspec/matchers'

RSpec::Matchers.define :be_running do |timeout = 30|
  match do |app|
    app_info = Machete::CF::AppInfo.new(app)

    start_time = Time.now
    max_end_time = start_time + timeout

    while Time.now <= max_end_time do
      return true if app_info.instance_count > 0
    end

    return false
  end

  failure_message do |app|
    "App is not running. Logs are:\n" +
      app.logs
  end
end