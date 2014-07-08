module Machete
  class SetupApp
    def execute(app)
      if app.with_pg
        database_server = server
        reset_database(app, database_server)
        insert_database_url!(app, database_server)
      end

      set_environment_variables(app)
    end

    private

    def reset_database(app, database_server)
      database = Database.new(
        database_name: database_name(app),
        server: database_server
      )

      database.clear
      database.create
    end

    def insert_database_url!(app, database_server)
      app.env['DATABASE_URL'] = url_builder.execute(
        database_name: database_name(app),
        server: database_server
      )
    end

    def set_environment_variables(app)
      set_app_env.execute(app)
    end

    def database_name(app)
      app.name
    end

    def server
      Database::Server.new
    end

    def url_builder
      Database::UrlBuilder.new
    end

    def set_app_env
      CF::SetAppEnv.new
    end
  end
end
