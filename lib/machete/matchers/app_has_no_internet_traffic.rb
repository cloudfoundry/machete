require 'rspec/matchers'

RSpec::Matchers.define :have_no_internet_traffic do | |
  match do |app|
    !app.cf_internet_log.include?('cf-to-internet-traffic')
  end

  failure_message do |app|
    "\nInternet traffic detected: \n\n" +
      app.cf_internet_log
  end
end