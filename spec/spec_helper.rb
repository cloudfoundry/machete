# encoding: utf-8
require 'rspec'
require 'machete'
require 'machete/matchers'
require 'timecop'

RSpec.configure do |config|
  config.color = true
  config.tty = true

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  config.before do
    allow(Kernel).to receive(:sleep)
  end
end
