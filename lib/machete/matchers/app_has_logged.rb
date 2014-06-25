require 'rspec/matchers'

RSpec::Matchers.define :have_logged do |expected_entry|
  match do |app|
    app_log = Machete::CF::AppLog.new(app)
    app_log.contents.include? expected_entry
  end
end