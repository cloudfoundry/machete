# encoding: utf-8
require 'logger'

module Machete
  class Logger < ::Logger
    def action(action)
      info("-----> #{action}")
    end
  end
end
