# encoding: utf-8

module Machete
  class Logger < ::Logger
    def action(action)
      info("-----> #{action}")
    end
  end
end
