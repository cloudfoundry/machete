require 'rspec/matchers'

RSpec::Matchers.define :have_logged do |expected_entry|
  match do |app|
    app_log = Machete::CF::AppLog.new(app)
    app_log.contents.include? expected_entry

  end

  failure_message do |app|
    app_log = Machete::CF::AppLog.new(app)
    "\nApp log did not include #{expected_entry} \n\n" +
      app_log.contents
  end

  failure_message_when_negated do |app|
    app_log = Machete::CF::AppLog.new(app)
    "\nApp log did include #{expected_entry} \n\n" +
      app_log.contents
  end
end