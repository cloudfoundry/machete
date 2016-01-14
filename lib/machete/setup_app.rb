module Machete
  class SetupApp
    def execute(app)
      app.env.each do |env_variable, value|
        SystemHelper.run_cmd("cf set-env #{app.name} #{env_variable} #{value}")
      end

      SystemHelper.run_cmd(%Q{cf cups #{app.name}-test-service -p '{"username":"AdM1n","password":"pa55woRD"}'})
      SystemHelper.run_cmd(%Q{cf bind-service #{app.name} #{app.name}-test-service})
    end
  end
end
