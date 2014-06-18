require 'rspec/matchers'

RSpec::Matchers.define :be_running do | |
  match do |app|
    app.number_of_running_instances > 0
  end

  failure_message do |app|
    "App is not running. Logs are:\n" +
      app.logs
  end
end