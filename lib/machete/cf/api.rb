# encoding: utf-8
module Machete
  module CF
    class API
      def execute
        SystemHelper.run_cmd('cf api').chomp
      end
    end
  end
end
