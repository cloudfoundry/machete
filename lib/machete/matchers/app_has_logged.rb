# encoding: utf-8
require 'rspec/matchers'

RSpec::Matchers.define :have_logged do |expected_entry|
  match do |app|
    app_log = Machete::CF::AppLog.new(app)

    if expected_entry.is_a? String
      app_log.contents.include?(expected_entry)
    elsif expected_entry.is_a? Regexp
      !app_log.contents.match(expected_entry).nil?
    end
  end

  failure_message do |app|
    app_log = Machete::CF::AppLog.new(app)
    "\nApp log did not include '#{expected_entry}'\n\n" +
      app_log.contents
  end

  failure_message_when_negated do |app|
    app_log = Machete::CF::AppLog.new(app)
    "\nApp log did include '#{expected_entry}'\n\n" +
      app_log.contents
  end
end
