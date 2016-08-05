# encoding: utf-8
require 'rspec/matchers'

RSpec::Matchers.define :have_logged do |expected_entry, timeout = 10|
  match do |app|
    searched_initial_logs = false
    max_end_time = Time.now + timeout

    while Time.now <= max_end_time
      app_logs = app.get_logs
      app_logs += app.get_recent_logs if searched_initial_logs

      if expected_entry.is_a?(String) && app_logs.include?(expected_entry)
        return true
      elsif expected_entry.is_a?(Regexp) && !app_logs.match(expected_entry).nil?
        return true
      end
      Kernel.sleep(1)
      searched_initial_logs = true
    end

    return false
  end

  failure_message do |app|
<<-FAILURE_MESSAGE

App log did not include '#{expected_entry}'
---------------------
App Logs:
---------------------
#{app.get_logs}
---------------------
App Recent Logs:
---------------------
#{app.get_recent_logs}
FAILURE_MESSAGE
  end

  failure_message_when_negated do |app|
<<-FAILURE_MESSAGE

App log did include '#{expected_entry}'
---------------------
App Logs:
---------------------
#{app.get_logs}
---------------------
App Recent Logs:
---------------------
#{app.get_recent_logs}
FAILURE_MESSAGE
  end
end
