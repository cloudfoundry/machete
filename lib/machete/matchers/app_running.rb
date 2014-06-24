require 'rspec/matchers'

RSpec::Matchers.define :be_running do |timeout = 30|
  match do |app|
    start_time = Time.now
    while Time.now < start_time + timeout do
      return true if app.number_of_running_instances > 0
    end

    return false
  end

  failure_message do |app|
    "App is not running. Logs are:\n" +
      app.logs
  end
end