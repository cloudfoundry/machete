#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'

module Machete
  class BuildpackTestRunner
    attr_reader :stack, :mode, :host, :should_build, :should_upload, :rspec_options

    def initialize(args)
      @stack = 'cflinuxfs2'
      @host = "local.pcfdev.io"
      @mode = 'cached'
      @should_build = true
      @should_upload = true
      @rspec_options = 'cf_spec'

      set_values_from_args(process_args(args))
    end

    def run!
      indent "Using the stack '#{@stack}' against the host '#{@host}'"

      indent "Fetching CF CLI details"
      system "which cf"
      system "cf --version"

      setup_buildpacks

      indent "Running specs"

      rspec_command = <<-COMMAND
BUNDLE_GEMFILE=cf.Gemfile BUILDPACK_MODE=#{@mode} CF_STACK=#{@stack} bundle exec rspec \
  --require rspec/instafail \
  --format RSpec::Instafail \
  --format documentation \
  --color \
  #{@rspec_options}
      COMMAND

      puts "Running the following rspec command:"
      puts rspec_command
      puts

      system rspec_command
    end

    def setup_buildpacks
      if @should_build && @should_upload
        build_new_buildpack
      end

      indent "Connecting to CF"

      script_dir = File.expand_path(File.join(__dir__, '..', '..', 'scripts'))

      system "#{script_dir}/cf_login_and_setup #{@host}"

      if @should_upload
        puts "Disabling all buildpacks"
        disabled_buildpacks = disable_buildpacks

        setup_signal_handling_enable_buildpacks(disabled_buildpacks)
        upload_new_buildpack
      end
    end

    def usage
      <<-USAGE
Usage: buildpack-build [options]

Options:
    [--stack=STACK]       # Specifies the stack that the test will run against.
                          # Default: cflinuxfs2
                          # Possible values: cflinuxfs2
    [--host=HOST]         # Specifies the host to target for running tests.
                          # Example: edge-1.buildpacks-gcp.ci.cf-app.com
                          # Default: local.pcfdev.io
    [--cached]            # Specifies the test run of a buildpack with vendored dependencies
                          # Default: true
    [--uncached]          # Specifies the test run of a buildpack without vendored dependencies
                          # Default: false
    [--no-build]          # Specifies whether to build the targeted buildpack.
                          # Default: true
    [--no-upload]         # Specifies whether to upload local buildpack to cf. Overrides '--no-build' flag to true.
                          # Default: true

Builds, uploads, and runs tests against a specified BUILDPACK.
Any other supplied arguments will be passed as rspec arguments!
USAGE
    end

    def indent(str)
      puts
      puts "******* #{str}"
    end

    def disable_buildpacks
      cf_buildpacks_output = `cf buildpacks`
      buildpack_output_lines = cf_buildpacks_output.split("\n")
      disabled_buildpacks = []

      buildpack_line_regex = /(.*)\s+\d+\s+(true|false)\s+(true|false).*$/

      buildpack_output_lines.each do |buildpack_line|
        if buildpack_line_regex.match(buildpack_line)
          buildpack_name = $1.strip
          buildpack_enabled = $2.strip
          if buildpack_enabled == 'true'
            update_successful = system("cf update-buildpack #{buildpack_name} --disable 1>&2")
            disabled_buildpacks << buildpack_name if update_successful
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

    def validate_stack_option
      if @stack != "cflinuxfs2"
        arg_error = <<-ERROR
  ERROR: Invalid argument passed in for --stack option.
  The valid --stack options are [ 'cflinuxfs2' ]
ERROR
        raise ArgumentError.new(arg_error)
      end
    end

    def buildpack_zip_files
      if @mode == "cached"
        Dir["*_buildpack-cached-v*.zip"]
      elsif @mode == "uncached"
        Dir["*_buildpack-v*.zip"]
      end
    end

    def build_new_buildpack
      indent "Building #{@mode} buildpack"
      FileUtils.rm_rf(buildpack_zip_files)
      raise "Buildpack packaging failed!" unless system("BUNDLE_GEMFILE=cf.Gemfile bundle exec buildpack-packager --#{@mode}")
    end

    def upload_new_buildpack
      language = detect_language

      indent "Uploading buildpack to CF"
      system "cf delete-buildpack #{language}-test-buildpack -f"
      system "cf create-buildpack #{language}-test-buildpack #{buildpack_zip_files.first} 1 --enable"
    end

    def detect_language
      indent "Detecting language"
      buildpack_zip_file = buildpack_zip_files.first
      detected_language = buildpack_zip_file.split('_').first
      indent "Language detected: #{detected_language}"
      detected_language
    end

    def setup_signal_handling_enable_buildpacks(disabled_buildpacks)
      %w(HUP INT QUIT ABRT TERM EXIT).each do |sig|
        Signal.trap(sig) do
          enable_buildpacks(disabled_buildpacks)
          if sig != 'EXIT'
            exit 1
          end
        end
      end
    end

    private

    def set_values_from_args(options)
      if options[:mode]
        @mode = options[:mode]
      end
      if options[:no_build]
        @should_build = false
      end
      if options[:no_upload]
        @should_build = false
        @should_upload = false
      end
      if options[:host]
        @host = options[:host]
      end
      if options[:stack]
        @stack = options[:stack]
        validate_stack_option
      end
      if options[:rspec]
        @rspec_options = options[:rspec].join(' ')
      end
    end

    def process_args(args)
      #manual parsing
      options = {}
      rspec_options = []

      while args.count > 0 do
        arg = args.shift

        case arg
        when '-h', '--help', 'help'
          puts usage
          exit 0
        when /\-\-stack=(.*)/
          options[:stack] = $1
        when /\-\-host=(.*)/
          options[:host] = $1
        when '--cached'
          options[:mode] = 'cached'
        when '--uncached'
          options[:mode] = 'uncached'
        when '--no-build'
          options[:no_build] = true
        when '--no-upload'
          options[:no_build] = true
          options[:no_upload] = true
        else
          rspec_options.push arg
        end
      end

      options[:rspec] = rspec_options unless rspec_options.empty?
      options
    end
  end
end
