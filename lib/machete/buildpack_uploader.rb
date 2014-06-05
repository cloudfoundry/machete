module Machete
  class BuildpackUploader
    attr_reader :language, :location

    def initialize(language, location = ".")
      @language = language
      @location = location

      setup_language_buildpack
    end

    private

    def setup_language_buildpack
      Machete.logger.action("Installing buildpack for: #{language} in #{buildpack_mode} mode")

      Bundler.with_clean_env do
        if File.exists?("#{location}/bin/package")
          package_command = "./bin/package #{buildpack_mode}"
        else
          package_command = "bundle && #{online_string_var} bundle exec rake package"
        end

        Machete.logger.info %x(
          cd #{location} &&
          rm -f #{language}_buildpack.zip &&
          #{package_command} &&
          (cf create-buildpack #{language}-test-buildpack #{language}_buildpack.zip 1 --enable &&
          cf update-buildpack #{language}-test-buildpack -p #{language}_buildpack.zip --enable) &&
          rm #{language}_buildpack.zip
        )
      end

      if $? != 0
        Machete.logger.warn "Could not create the #{language} test buildpack"
        exit(false)
      end

    end

    def buildpack_mode
      BuildpackMode.offline? ? "offline" : "online"
    end

    def online_string_var
      if BuildpackMode.offline?
        ""
      else
        "ONLINE=1"
      end
    end

  end
end
