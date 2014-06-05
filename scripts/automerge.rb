#!/usr/bin/env ruby


def push_merge
  if system "cd tmp/buildpacks/cf-buildpack-ruby && git push origin master"
    exit 0
  else
    puts "Could not push the merged ruby buildpack"
    exit 1
  end

end

def run_specs
  if system "BUILDPACK_ROOT=tmp/buildpacks bundle exec rspec spec/integration/ruby && BUILDPACK_ROOT=tmp/buildpacks BUILDPACK_MODE=offline bundle exec rspec spec/integration/ruby"
    push_merge
  else
    exit 1
  end
end

begin
  `rm -rf tmp`
  `mkdir -p tmp/buildpacks`

  `git clone https://github.com/cloudfoundry/cf-buildpack-ruby tmp/buildpacks/cf-buildpack-ruby`
  `git clone https://github.com/pivotal-cf-experimental/cf-buildpack-go tmp/buildpacks/cf-buildpack-go`

  Dir.chdir("tmp/buildpacks/cf-buildpack-ruby")

  `git remote add heroku-github https://github.com/heroku/heroku-buildpack-ruby`
  `git fetch heroku-github`
  output = `git merge heroku-github/master`
  puts output
  Dir.chdir("../../..")

  if output.match(/up-to-date/)
    puts "Up to date, not doing anything"
  elsif output.match(/CONFLICT/)
    puts "Merge conflicts must be resolved manually"
    exit 1
  else
    puts "Merge successful, running the tests"
    run_specs()
  end
rescue StandardError => e
  puts e
  puts "---> Backtrace"
  puts e.backtrace.join("\n")
  puts "Something went wrong during auto merge, investigate"
  exit 1
end
