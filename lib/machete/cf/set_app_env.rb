module Machete
  module CF
    class SetAppEnv
      def execute(app)
        app.env.each do |env_variable, value|
          SystemHelper.run_cmd("cf set-env #{app.name} #{env_variable} #{value}")
        end
      end
    end
  end
end