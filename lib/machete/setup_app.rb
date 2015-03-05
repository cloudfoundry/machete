module Machete
  class SetupApp
    def execute(app)
      if app.with_pg
        database_manager = database_manager(app)
        reset_database(app, database_manager)
        insert_database_url!(app, database_manager)
      end

      set_environment_variables(app)
    end

    private

    def reset_database(app, database_manager)
      database = Database.new(
        database_name: database_name(app),
        database_manager: database_manager
      )

      database.create
    end

    def insert_database_url!(app, database_manager)
      app.env['DATABASE_URL'] = url_builder.execute(
        database_name: database_name(app),
        database_manager: database_manager
      )
    end

    def set_environment_variables(app)
      set_app_env.execute(app)
    end

    def database_name(app)
      app.name
    end

    def database_manager(app)
      @database_manager ||= app.host.create_db_manager
    end

    def url_builder
      Database::UrlBuilder.new
    end

    def set_app_env
      CF::SetAppEnv.new
    end
  end
end
