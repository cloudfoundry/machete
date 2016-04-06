# encoding: utf-8
require 'rspec/matchers'
require 'erb'
require 'yaml'
require 'socket'
require 'tmpdir'

RSpec::Matchers.define :use_proxy_during_staging do
  dockerfile = <<-DOCKERFILE
FROM cloudfoundry/cflinuxfs2

ENV CF_STACK cflinuxfs2
<%= docker_env_vars %>

ADD <%= fixture_path %> /tmp/staged/
ADD ./<%= cached_buildpack_path %> /tmp/

RUN mkdir -p /buildpack
RUN mkdir -p /tmp/cache

RUN unzip /tmp/<%= cached_buildpack_path %> -d /buildpack
RUN (sudo tcpdump -n -i eth0 not udp port 53 and ip -t -w /tmp/dumplog &) && /buildpack/bin/detect /tmp/staged && /buildpack/bin/compile /tmp/staged /tmp/cache && /buildpack/bin/release /tmp/staged /tmp/cache && pkill tcpdump; tcpdump -nr /tmp/dumplog || true
  DOCKERFILE

  match do |app|
    begin
      cached_buildpack_path = Dir['*_buildpack-v*.zip'].fetch(0)
      fixture_path = "./#{app.src_directory}"

      dockerfile_path = "Dockerfile.#{$PROCESS_ID}.#{Time.now.to_i}"
      docker_image_name = 'proxy_staging_test'

      manifest_search = Dir.glob("#{fixture_path}/**/manifest.yml")
      manifest_location = ''
      manifest_hash = {}
      unless manifest_search.empty?
        manifest_location = File.expand_path(manifest_search[0])
        manifest_hash = YAML.load_file(manifest_location)
      end
      docker_env_vars = ''
      if manifest_hash.key?('env')
        manifest_hash['env'].each do |key, value|
          docker_env_vars << "ENV #{key} #{value}\n"
        end
      end

      # setting proxy env vars
      proxy_ip = Socket.ip_address_list.select{ |ip| ip.ip_address =~ /^[\d\.]+$/ }.last.ip_address
      proxy_port = '8080'
      docker_env_vars << "ENV http_proxy http://#{proxy_ip}:#{proxy_port}\n"
      docker_env_vars << "ENV https_proxy https://#{proxy_ip}:#{proxy_port}\n"

      # boot up proxy in background
      proxy_process = nil
      go_code = <<EOF
package main

import (
    "github.com/elazarl/goproxy"
    "log"
    "net/http"
)

func main() {
    proxy := goproxy.NewProxyHttpServer()
    proxy.Verbose = true
    log.Fatal(http.ListenAndServe(":8080", proxy))
}
EOF

      tmpdir = Dir.mktmpdir
      proxy_dir = File.join(tmpdir, 'go/src/proxy')
      FileUtils.mkdir_p(proxy_dir)
      File.write(File.join(proxy_dir, 'main.go'), go_code)
      Dir.chdir(proxy_dir) do
        `GOPATH=#{tmpdir} go get ./...`
        `GOPATH=#{tmpdir} go build`
        proxy_process = fork { exec("#{proxy_dir}/proxy") }
      end

      dockerfile_contents = ERB.new(dockerfile).result binding
      File.write(dockerfile_path, dockerfile_contents)

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

      @traffic_lines = docker_output.split("\n").grep(/IP ([\d+\.]+) > ([\d+\.]+)\.(\d+)/)
    ensure
      unless `docker images | grep #{docker_image_name}`.strip.empty?
        `docker rmi -f #{docker_image_name}`
      end
      FileUtils.rm_f(tmpdir) if defined? tmpdir
      FileUtils.rm(dockerfile_path) if defined? dockerfile_path && !dockerfile_path.nil?
      Process.kill('KILL', proxy_process) if defined? proxy_process && !proxy_process.nil?
    end

    fail "docker didn't successfully build" unless docker_exitstatus == 0

    #check all traffic lines hit proxy
    return @traffic_lines.all? do |traffic_line|
      /IP ([\d+\.]+) > ([\d+\.]+)\.(\d+)/.match(traffic_line)
      source_ip_port = $1
      destination_ip = $2
      destination_port = $3
      #ignore screening of traffic that comes from proxy
      if source_ip_port == "#{proxy_ip}.#{proxy_port}"
        true
      else
        destination_ip == proxy_ip && destination_port == proxy_port
      end
    end
  end

  failure_message do
    "Proxy was not used for internet traffic during staging\n\n" +
      @traffic_lines.join("\n")
  end

  failure_message_when_negated do
    "\nProxy used during staging:\n\n" +
      @traffic_lines.join("\n")
  end
end
