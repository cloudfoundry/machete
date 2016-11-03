# encoding: utf-8
require 'rspec/matchers'
require 'yaml'
require 'socket'
require 'tmpdir'
require 'machete/matchers/matcher_helpers'

RSpec::Matchers.define :use_proxy_during_staging do
  include Machete::MatcherHelpers

  match do |app|
    begin
      docker_image_name = 'proxy_staging_test'

      docker_env_vars = ''
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
    log.Fatal(http.ListenAndServe(":#{proxy_port}", proxy))
}
EOF
      tmpdir = Dir.mktmpdir
      proxy_dir = File.join(tmpdir, 'go/src/proxy')
      gopath_dir = File.join(tmpdir, 'go')
      FileUtils.mkdir_p(proxy_dir)
      File.write(File.join(proxy_dir, 'main.go'), go_code)

      Dir.chdir(proxy_dir) do
        `GOPATH=#{gopath_dir} go get ./...`
        `GOPATH=#{gopath_dir} go build`
        proxy_process = fork { exec("#{proxy_dir}/proxy") }
      end

      network_command = '(sudo tcpdump -n -i eth0 not udp port 53 and ip -t -Uw /tmp/dumplog &) && /buildpack/bin/detect /tmp/staged && /buildpack/bin/compile /tmp/staged /tmp/cache && /buildpack/bin/release /tmp/staged /tmp/cache && pkill tcpdump; tcpdump -nr /tmp/dumplog || true'

      docker_exitstatus, docker_output, dockerfile_path = execute_docker_file(app, :uncached, docker_image_name, docker_env_vars, network_command)

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
