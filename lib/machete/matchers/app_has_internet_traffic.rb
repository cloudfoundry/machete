require 'rspec/matchers'

RSpec::Matchers.define :have_internet_traffic do | |
  match do |host|
    host_log = Machete::Host::Log.new host
    host_log.contents.include?('cf-to-internet-traffic')
  end

  failure_message_when_negated do |host|
    host_log = Machete::Host::Log.new host

    "\nInternet traffic detected: \n\n" +
      host_log.contents
  end
end