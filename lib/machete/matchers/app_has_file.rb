# encoding: utf-8
require 'rspec/matchers'

RSpec::Matchers.define :have_file do |expected_filename|
  match do |app|
    app_file = Machete::CF::AppFile.new(app)
    app_file.has_file? expected_filename
  end
end
