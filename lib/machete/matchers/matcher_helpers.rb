module Machete
  module MatcherHelpers

    def execute_docker_file(app, buildpack_mode, docker_image_name, docker_env_vars, network_command)
      if buildpack_mode == :cached
        buildpack_path = Dir['*_buildpack-cached-v*.zip'].fetch(0)
      elsif buildpack_mode == :uncached
        buildpack_path = Dir['*_buildpack-v*.zip'].fetch(0)
      end
      fixture_path = "./#{app.src_directory}"

      dockerfile_path = "Dockerfile.#{$PROCESS_ID}.#{Time.now.to_i}"
      docker_image_name = 'internet_traffic_test'

      docker_env_vars += get_app_env_vars(fixture_path)

      dockerfile_contents = dockerfile(docker_env_vars, fixture_path, buildpack_path, network_command)

      File.write(dockerfile_path, dockerfile_contents)

      exit_status, output = execute_test_in_docker_container(dockerfile_path, docker_image_name)
      [exit_status, output, dockerfile_path]
    end

    def dockerfile(env_vars, fixture_path, buildpack_path, network_command)
          <<-DOCKERFILE
    FROM cloudfoundry/cflinuxfs2

    ENV CF_STACK cflinuxfs2
    ENV VCAP_APPLICATION {}
    #{env_vars}

    ADD #{fixture_path} /tmp/staged/
    ADD ./#{buildpack_path} /tmp/

    RUN mkdir -p /buildpack
    RUN mkdir -p /tmp/cache

    RUN unzip /tmp/#{buildpack_path} -d /buildpack

    # HACK around https://github.com/dotcloud/docker/issues/5490
    RUN mv /usr/sbin/tcpdump /usr/bin/tcpdump

    RUN #{network_command}
    DOCKERFILE
    end

    def get_app_env_vars(fixture_path)
      app_env_vars = ''

      manifest_search = Dir.glob("#{fixture_path}/**/manifest.yml")
      manifest_location = ''
      manifest_hash = {}

      unless manifest_search.empty?
        manifest_location = File.expand_path(manifest_search[0])
        manifest_hash = YAML.load_file(manifest_location)
      end

      if manifest_hash.key?('env')
        manifest_hash['env'].each do |key, value|
          app_env_vars += "ENV #{key} #{value}\n"
        end
      end

      app_env_vars
    end

    def execute_test_in_docker_container(dockerfile_path, docker_image_name)
      docker_exitstatus = 0

      docker_output = Dir.chdir(File.dirname(dockerfile_path)) do
        output = `docker build --rm --no-cache -t #{docker_image_name} -f #{dockerfile_path} .`
        docker_exitstatus = $CHILD_STATUS.exitstatus.to_i
        output
      end

      unless docker_exitstatus == 0
        puts '=========================================='
        puts "docker_output: #{docker_output}"
        puts '=========================================='
      end

      [docker_exitstatus, docker_output]
    end
  end
end
