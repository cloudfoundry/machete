# encoding: utf-8
require 'rspec/matchers'
require 'yaml'
require 'machete/matchers/matcher_helpers'

RSpec::Matchers.define :have_internet_traffic do
  include Machete::MatcherHelpers

  match do |app|
    begin
      docker_image_name = 'internet_traffic_test'
      docker_env_vars = ''
      network_command = "(sudo tcpdump -n -i eth0 not udp port 53 and ip -c 1 -t | sed -e 's/^[^$]/internet traffic: /' 2>&1 &) && /buildpack/bin/detect /tmp/staged && /buildpack/bin/compile /tmp/staged /tmp/cache && /buildpack/bin/release /tmp/staged /tmp/cache"

      docker_exitstatus, docker_output, dockerfile_path = execute_docker_file(app, :cached, docker_image_name, docker_env_vars, network_command)

      @traffic_lines = docker_output.split("\n").grep(/^(\e\[\d+m)?internet traffic:/)
    ensure
      unless `docker images | grep #{docker_image_name}`.strip.empty?
        `docker rmi -f #{docker_image_name}`
      end
      FileUtils.rm(dockerfile_path)
    end

    fail "docker didn't successfully build" unless docker_exitstatus == 0
    return !@traffic_lines.empty?
  end

  failure_message do
    'No Internet traffic was detected'
  end

  failure_message_when_negated do
    "\nInternet traffic detected:\n\n" +
      @traffic_lines.join("\n")
  end
end
