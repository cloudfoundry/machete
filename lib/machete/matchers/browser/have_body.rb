require 'rspec/matchers'

RSpec::Matchers.define :have_body do |expected_body|
  @page_body = ''
  match do |browser|
    @page_body = browser.body
    @page_body.include? expected_body
  end

  failure_message do |browser|
    "'#{expected_body}' not found in: \n\n" +
      @page_body
  end

  failure_message_when_negated do |browser|
    "'#{expected_body}' was found in: \n\n" +
      @page_body
  end
end
