require 'rspec/matchers'

RSpec::Matchers.define :have_page_body do |expected_page_body|
  @page_body = ''
  match do |app|
    app_page = Machete::CF::AppPage.new(app)
    @page_body = app_page.body
    @page_body.include? expected_page_body
  end

  failure_message do |app|
    "'#{expected_page_body}' not found in: \n\n" +
      @page_body
  end

  failure_message_when_negated do |host|
    "'#{expected_page_body}' was found in: \n\n" +
      @page_body
  end
end
