#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'

def usage
  <<~USAGE
    Usage: buildpack-build [options]

    Options:
        [--stack=STACK]       # Specifies the stack that the test will run against.
                              # Default: cflinuxfs2
                              # Possible values: cflinuxfs2
        [--host=HOST]         # Specifies the host to target for running tests.
                              # Example: ci=8.example.com
        [--cached]            # Specifies the test run of a buildpack with vendored dependencies
                              # Default: true
        [--uncached]          # Specifies the test run of a buildpack without vendored dependencies
                              # Default: false
        [--no-build]          # Specifies whether to build the targeted buildpack.
                              # Default: false
        [--no-upload]         # Specifies whether to upload local buildpack to cf. Overrides '--no-build' flag to true.
                              # Default: false

    Builds, uploads, and runs tests against a specified BUILDPACK.
    Any other supplied arguments will be passed as rspec arguments!
  USAGE
end

def indent(str)
  puts
  puts "******* #{str}"
end

#Returns disabled buildpack names
def disable_buildpacks
  cf_buildpacks_output = `cf buildpacks`
  buildpack_output_lines = cf_buildpacks_output.split("\n")
  disabled_buildpacks = []

  buildpack_line_regex = /(.*)\s+\d+\s+(true|false)\s+(true|false).*$/

  buildpack_output_lines.each do |buildpack_line|
    if buildpack_line_regex.match(buildpack_line)
      buildpack_name = $1.strip
      buildpack_enabled = $2.strip
      if buildpack_enabled
        puts `cf update-buildpack #{buildpack_name} --disable 1>&2`
        disabled_buildpacks << buildpack_name if $?.success?
      end
    end
  end
  disabled_buildpacks
end

def enable_buildpacks(buildpack_names)
  buildpack_names.each do |buildpack_name|
    puts `cf update-buildpack #{buildpack_name} --enable 1>&2`
  end
  puts "Restored original buildpacks enabled/disabled configuration"
end

def validate_stack_option(stack)
  if stack != "cflinuxfs2"
    puts "ERROR: Invalid argument passed in for --stack option."
    puts "The valid --stack options are [ 'cflinuxfs2' ]"
    exit 1
  end
end

def buildpack_zip_files(mode)
  if mode == "cached"
    Dir["*_buildpack-cached-v*.zip"]
  elsif mode == "uncached"
    Dir["*_buildpack-v*.zip"]
  end
end

def process_args(args)
  #manual parsing
  options = {}
  rspec_options = []

  while args.count > 0 do
    arg = args.shift

    case arg
    when '-h', '-?', '--help', 'help'
      usage
      exit 0
    when arg.match(/\-\-stack=(.*)/)
      options[:stack] = $1
    when arg.match(/\-\-host=(.*)/)
      options[:host] = $1
    when '--cached'
      options[:mode] = 'cached'
    when '--uncached'
      options[:mode] = 'uncached'
    when '--no-build'
      options[:should_build] = false
    when '--no-upload'
      options[:should_build] = false
      options[:should_upload] = false
    else
      rspec_options.push arg
    end
  end

  options[:rspec] = rspec_options unless rspec_options.empty?
  options
end


def build_new_buildpack(mode)
  indent "Building #{mode} buildpack"
  FileUtils.rm_rf(buildpack_zip_files(mode))
  system("BUNDLE_GEMFILE=cf.Gemfile bundle exec buildpack-packager --#{mode}")
end

def upload_new_buildpack(mode, language)
  indent "Uploading buildpack to CF"
  system "cf delete-buildpack #{language}-test-buildpack -f"
  system "cf create-buildpack #{language}-test-buildpack #{buildpack_zip_files(mode).first} 1 --enable"
end

def detect_language(mode)
  indent "Detecting language"
  buildpack_zip_file = buildpack_zip_files(mode).first
  language = buildpack_zip_file.split('_').first
  indent "Language detected: #{language}"
  language
end

def setup_signal_handling_enable_buildpacks(disabled_buildpacks)
  %w(HUP INT QUIT ABRT TERM EXIT).each do |sig|
    Signal.trap(sig) do
      enable_buildpacks(disabled_buildpacks)
      exit 1
    end
  end
end

stack = 'cflinuxfs2'
mode = 'cached'
should_build = true
should_upload = true
rspec_options = 'cf_spec'
host = "local.pcfdev.io"

options = process_args(ARGV)

if options[:mode]
  mode = options[:mode]
end

if options[:no_build]
  should_build = false
end
if options[:no_upload]
  should_build = false
  should_upload = false
end
if options[:host]
  host = options[:host]
end
if options[:stack]
  stack = options[:stack]
  validate_stack_option(stack)
end
if options[:rspec]
  rspec_options = options[:rspec].join(' ')
end




indent "Using the stack 'stack' against the host '$host'"

indent "Fetching CF CLI details"
system "which cf"
system "cf --version"

if should_build
  build_new_buildpack(mode)
  detect_language(mode)
end

indent "Connecting to CF"

script_dir = File.expand_path(__dir__)

system "#{script_dir}/cf_login_and_setup #{host}"

if should_upload
  language = detect_language(mode)

  puts "Disabling all buildpacks"
  disabled_buildpacks = disable_buildpacks

  setup_signal_handling_enable_buildpacks(disabled_buildpacks)
  upload_new_buildpack(mode, language)
end

indent "Running specs"

# Command

rspec_command = <<~COMMAND
BUNDLE_GEMFILE=cf.Gemfile BUILDPACK_MODE=#{mode} CF_STACK=#{stack} bundle exec rspec \
  --require rspec/instafail \
  --format RSpec::Instafail \
  --format documentation \
  --color \
  #{rspec_options}
COMMAND

puts "Running the following rspec command:"
puts rspec_command
puts

system rspec_command
