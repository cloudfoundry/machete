# encoding: utf-8
require 'rspec/matchers'

RSpec::Matchers.define :have_header do |expected_header|
  @page_headers = ''

  match do |browser|
    @page_headers = browser.headers

    @page_headers.any? do |k, v|
      k == expected_header.downcase || v.include?(expected_header)
    end
  end

  failure_message do |_browser|
    "'#{expected_header}' not found in: \n\n#{@page_headers}"
  end

  failure_message_when_negated do |_browser|
    "'#{expected_header}' was found in: \n\n#{@page_headers}"
  end
end
