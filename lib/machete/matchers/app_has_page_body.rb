require 'rspec/matchers'

RSpec::Matchers.define :have_page_body do |expected_page_body|
  match do |app|
    app_page = Machete::CF::AppPage.new(app)
    app_page.body.include? expected_page_body
  end
end