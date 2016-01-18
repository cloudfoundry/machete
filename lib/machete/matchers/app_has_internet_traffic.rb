require 'rspec/matchers'
require 'erb'

RSpec::Matchers.define :have_internet_traffic do
  dockerfile = <<-DOCKERFILE
FROM cloudfoundry/cflinuxfs2

ENV CF_STACK cflinuxfs2

ADD <%= fixture_path %> /tmp/staged/
ADD ./<%= cached_buildpack_path %> /tmp/

RUN mkdir -p /buildpack
RUN mkdir -p /tmp/cache

RUN unzip /tmp/<%= cached_buildpack_path %> -d /buildpack
RUN (sudo tcpdump -n -i eth0 not udp port 53 and ip -c 1 -t | sed -e 's/^[^$]/internet traffic: /' 2>&1 &) \
 && /buildpack/bin/detect /tmp/staged \
 && /buildpack/bin/compile /tmp/staged /tmp/cache \
 && /buildpack/bin/release /tmp/staged /tmp/cache
  DOCKERFILE

  match do |app|
    begin
      cached_buildpack_path = Dir['*_buildpack-cached-v*.zip'].fetch(0)
      fixture_path = "./cf_spec/fixtures/#{app_name}"

      dockerfile_path = "Dockerfile.#{$$}.#{Time.now.to_i}"
      dockerfile_contents = ERB.new(dockerfile).result binding
      File.write(dockerfile_path, dockerfile_contents)

      docker_output = Dir.chdir(File.dirname(dockerfile_path)) do
        `docker build --rm --no-cache -f #{dockerfile_path} .`
      end
      @traffic_lines = docker_output.split("\n").grep(/^(\e\[\d+m)?internet traffic:/)
      return !@traffic_lines.empty?
    ensure
      FileUtils.rm(dockerfile_path)
    end
  end

  failure_message do
    "No Internet traffic was detected"
  end

  failure_message_when_negated do
    "\nInternet traffic detected:\n\n" +
    @traffic_lines.join("\n")
  end
end
