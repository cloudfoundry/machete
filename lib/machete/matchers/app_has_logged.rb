# encoding: utf-8
require 'rspec/matchers'

RSpec::Matchers.define :have_logged do |expected_entry, timeout = 10|
  match do |app|
    max_end_time = Time.now + timeout

    while Time.now <= max_end_time
      app_logs = app.get_logs
      if expected_entry.is_a?(String) && app_logs.include?(expected_entry)
        return true
      elsif expected_entry.is_a?(Regexp) && !app_logs.match(expected_entry).nil?
        return true
      end
      Kernel.sleep(1)
    end

    return false
  end

  failure_message do |app|
    "\nApp log did not include '#{expected_entry}'\n\n" +
      app.get_logs
  end

  failure_message_when_negated do |app|
    "\nApp log did include '#{expected_entry}'\n\n" +
      app.get_logs
  end
end
