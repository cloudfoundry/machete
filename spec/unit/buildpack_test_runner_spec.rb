# encoding: utf-8
require 'spec_helper'
require 'tmpdir'
require 'fileutils'

module Machete
  describe BuildpackTestRunner do
    let(:args) { [] }

    subject { described_class.new(args) }

    describe '#initialize' do
      context 'with no arguments' do
        it 'sets the appropriate defaults' do
          expect(subject.stack).to eq('cflinuxfs2')
          expect(subject.mode).to eq('cached')
          expect(subject.host).to eq('local.pcfdev.io')
          expect(subject.should_upload).to eq(true)
          expect(subject.should_build).to eq(true)
          expect(subject.rspec_options).to eq('cf_spec')
        end
      end

      context 'while indicating a valid stack' do
        let(:args) { ['--stack=cflinuxfs2'] }

        it 'sets stack' do
          expect(subject.stack).to eq('cflinuxfs2')
        end
      end

      context 'while indicating an invalid stack' do
        let(:args) { ['--stack=weird_stack'] }

        it 'errors and warns about invalid stack arg' do
          expect { subject }.to raise_error(ArgumentError,
                                            /Invalid argument passed in for --stack option/)
        end
      end

      context 'while indicating a host' do
        let(:args) { ['--host=some-cf-deployment.com'] }

        it 'sets host' do
          expect(subject.host).to eq('some-cf-deployment.com')
        end
      end

      context 'while indicating cached buildpack' do
        let(:args) { ['--cached'] }

        it 'sets mode to cached' do
          expect(subject.mode).to eq('cached')
        end
      end

      context 'while indicating uncached buildpack' do
        let(:args) { ['--uncached'] }

        it 'sets mode to uncached' do
          expect(subject.mode).to eq('uncached')
        end
      end

      context 'while indicating not to build' do
        let(:args) { ['--no-build'] }

        it 'sets build to false and upload to true' do
          expect(subject.should_build).to eq(false)
          expect(subject.should_upload).to eq(true)
        end
      end

      context 'while indicating not to upload' do
        let(:args) { ['--no-upload'] }

        it 'sets build to false and upload to false' do
          expect(subject.should_build).to eq(false)
          expect(subject.should_upload).to eq(false)
        end
      end

      context 'while indicating rspec options' do
        let(:args) { %w(cf_spec --stack=cflinuxfs2 --host=pcfdev --tag language:ruby) }

        it 'picks out the rspec options' do
          expect(subject.rspec_options).to eq('cf_spec --tag language:ruby')
        end
      end

      context 'while indicating help' do
        let(:args) { %w(cf_spec --stack=cflinuxfs2 --help) }

        it 'prints help message and exits' do
          expect_any_instance_of(described_class).to receive(:usage)
          expect_any_instance_of(described_class).to receive(:puts)
          expect{subject}.to raise_exception(SystemExit)
        end
      end
    end

    describe '#run!' do
      let(:test_dir) { Dir.mktmpdir }
      let(:rspec_command) do
        <<-COMMAND
BUNDLE_GEMFILE=cf.Gemfile BUILDPACK_MODE=cached CF_STACK=cflinuxfs2 SHARED_HOST=false bundle exec rspec \
  --require rspec/instafail \
  --format RSpec::Instafail \
  --format documentation \
  --color \
  cf_spec
        COMMAND
      end

      before do
        allow(subject).to receive(:system)
        allow(subject).to receive(:puts)
        @current_dir = Dir.pwd
        Dir.chdir test_dir
        File.write("test_buildpack-v3.3.3.zip", "xxx")
      end

      after do
        FileUtils.rm_rf(test_dir)
        Dir.chdir @current_dir
      end

      it 'setups the buildpacks and runs rspec' do
        expect(subject).to receive(:setup_buildpacks).ordered
        expect(subject).to receive(:system).with(rspec_command).ordered

        subject.run!
      end
    end

    describe '#disable_buildpacks' do
      let(:cf_buildpacks_output) do
        <<-CF_BUILDPACKS
Getting buildpacks...

buildpack                    position   enabled   locked   filename
binary-buildpack             1          false     false    binary_buildpack-cached-v1.0.5.zip
staticfile-buildpack         2          true      false    staticfile_buildpack-cached-v1.3.12.zip
dotnet-core-buildpack        3          false     false    dotnet-core_buildpack-cached-v1.0.4.zip
go-buildpack                 4          true      false    go_buildpack-cached-v1.7.14.zip
           CF_BUILDPACKS
      end

      before do
        allow(subject).to receive(:puts)
        allow(subject).to receive(:system).and_return(true)
        allow(subject).to receive(:`).with('cf buildpacks').and_return(cf_buildpacks_output)
      end

      it 'tries to disable all enabled buildpacks' do
        expect(subject).to receive(:system).with('cf update-buildpack staticfile-buildpack --disable 1>&2').and_return(true)
        expect(subject).to receive(:system).with('cf update-buildpack go-buildpack --disable 1>&2').and_return(true)
        expect(subject).to_not receive(:system).with('cf update-buildpack binary-buildpack --disable 1>&2')
        expect(subject).to_not receive(:system).with('cf update-buildpack dotnet-core-buildpack --disable 1>&2')
        subject.disable_buildpacks
      end

      it 'returns a list of the buildpacks it disabled' do
        expect(subject.disable_buildpacks).to eq(%w(staticfile-buildpack go-buildpack))
      end
    end

    describe '#enable_buildpacks' do
      let(:buildpack_names) { %w(staticfile-buildpack dotnet-core-buildpack) }

      before { allow(subject).to receive(:puts) }

      it 'tries to enable the specified buildpacks' do
        expect(subject).to receive(:`).with('cf update-buildpack staticfile-buildpack --enable 1>&2')
        expect(subject).to receive(:`).with('cf update-buildpack dotnet-core-buildpack --enable 1>&2')
        subject.enable_buildpacks(buildpack_names)
      end
    end

    describe '#setup_buildpacks' do
      let(:args) { ['--uncached'] }
      let(:disabled_buildpacks) { double(:disabled_buildpacks) }
      let(:test_dir) { Dir.mktmpdir }

      before do
        allow(subject).to receive(:puts)
        @current_dir = Dir.pwd
        Dir.chdir test_dir
        File.write("test_buildpack-v3.3.3.zip", "xxx")
      end

      after do
        FileUtils.rm_rf(test_dir)
        Dir.chdir @current_dir
      end

      context 'should upload and build' do
        it 'builds a new buildpack  and uploads it cf' do
          expect(subject).to receive(:build_new_buildpack).ordered
          script_dir = File.expand_path(File.join(__dir__, '..', '..', 'scripts'))
          expect(subject).to receive(:system).with(/#{script_dir}\/cf_login_and_setup local.pcfdev.io integration-test/).ordered
          expect(subject).to receive(:disable_buildpacks).and_return(disabled_buildpacks).ordered
          expect(subject).to receive(:setup_signal_handling).with(disabled_buildpacks).ordered
          expect(subject).to receive(:upload_new_buildpack).with(no_args).ordered
          subject.setup_buildpacks
        end
      end

      context 'should not build' do
        let(:args) { ['--uncached', '--no-build'] }

        it 'uploads an existing buildpack to cf' do
          expect(subject).to_not receive(:build_new_buildpack)
          script_dir = File.expand_path(File.join(__dir__, '..', '..', 'scripts'))
          expect(subject).to receive(:system).with(/#{script_dir}\/cf_login_and_setup local.pcfdev.io integration-test/).ordered
          expect(subject).to receive(:disable_buildpacks).and_return(disabled_buildpacks).ordered
          expect(subject).to receive(:setup_signal_handling).with(disabled_buildpacks).ordered
          expect(subject).to receive(:upload_new_buildpack).with(no_args).ordered
          subject.setup_buildpacks
        end
      end

      context 'should not upload' do
        let(:args) { ['--uncached', '--no-upload'] }

        it 'neither builds nor uploads any buildpacks' do
          expect(subject).to_not receive(:build_new_buildpack)
          script_dir = File.expand_path(File.join(__dir__, '..', '..', 'scripts'))
          expect(subject).to receive(:system).with(/#{script_dir}\/cf_login_and_setup local.pcfdev.io integration-test/).ordered
          expect(subject).to_not receive(:disable_buildpacks)
          expect(subject).to_not receive(:setup_signal_handling)
          expect(subject).to_not receive(:upload_new_buildpack)
          subject.setup_buildpacks
        end
      end

      context 'shared host' do
        let(:args) { ['--uncached', '--shared-host'] }

        it 'does not disable any buildpacks and uploads the specified language buildpack' do
          expect(subject).to receive(:build_new_buildpack).ordered
          script_dir = File.expand_path(File.join(__dir__, '..', '..', 'scripts'))
          expect(subject).to receive(:system).with(/#{script_dir}\/cf_login_and_setup local.pcfdev.io integration-test/).ordered
          expect(subject).to_not receive(:disable_buildpacks)
          expect(subject).to receive(:setup_signal_handling).with([])
          expect(subject).to receive(:upload_new_buildpack).with("test_buildpack").ordered
          subject.setup_buildpacks
        end
      end
    end

    describe '#upload_new_buildpack' do
      before do
        allow(subject).to receive(:puts)

        @current_dir = Dir.pwd
        @temp_dir = Dir.mktmpdir
        Dir.chdir(@temp_dir)

        `touch #{buildpack_filename}`
      end

      after do
        Dir.chdir(@current_dir)
        FileUtils.rm_rf(@temp_dir)
      end

      context 'with an uncached ruby buildpack' do
        let(:args)               { ['--uncached' ] }
        let(:buildpack_filename) { 'ruby_buildpack-v1.0.5.zip' }

        it 'tries to delete an existing test buildpack and upload a new uncached one' do
          expect(subject).to receive(:system).with("cf delete-buildpack ruby-test-buildpack -f")
          expect(subject).to receive(:system).with("cf create-buildpack ruby-test-buildpack ruby_buildpack-v1.0.5.zip 1 --enable")
          subject.upload_new_buildpack
        end
      end
      context 'with a cached ruby buildpack' do
        let(:args)               { ['--cached' ] }
        let(:buildpack_filename) { 'ruby_buildpack-cached-v1.0.5.zip' }

        it 'tries to delete an existing test buildpack and upload a new cached one' do
          expect(subject).to receive(:system).with("cf delete-buildpack ruby-test-buildpack -f")
          expect(subject).to receive(:system).with("cf create-buildpack ruby-test-buildpack ruby_buildpack-cached-v1.0.5.zip 1 --enable")
          subject.upload_new_buildpack
        end
      end
    end
  end
end
