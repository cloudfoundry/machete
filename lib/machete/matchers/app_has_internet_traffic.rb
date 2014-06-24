require 'rspec/matchers'

RSpec::Matchers.define :have_internet_traffic do | |
  match do |app|
    app.cf_internet_log.include?('cf-to-internet-traffic')
  end

  failure_message_when_negated do |app|
    "\nInternet traffic detected: \n\n" +
      app.cf_internet_log
  end
end