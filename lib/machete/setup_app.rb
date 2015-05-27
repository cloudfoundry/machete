module Machete
  class SetupApp
    def execute(app)
      set_environment_variables(app)
    end

    private

    def set_environment_variables(app)
      set_app_env.execute(app)
    end

    def set_app_env
      CF::SetAppEnv.new
    end
  end
end
