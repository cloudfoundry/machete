require 'rspec/matchers'

RSpec::Matchers.define :be_staged do | |
  match do |app|
    app.staged?
  end

  failure_message do |app|
    "App is not staged. Logs are:\n" +
      app.logs
  end
end