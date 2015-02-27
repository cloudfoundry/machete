require 'rspec/matchers'

RSpec::Matchers.define :have_internet_traffic do | |
  match do |host|
    host_log = host.create_log_manager
    host_log.logged_internet_traffic?
  end

  failure_message_when_negated do |host|
    host_log = host.create_log_manager

    "\nInternet traffic detected: \n\n" +
      host_log.contents
  end
end
