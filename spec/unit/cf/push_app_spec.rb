# encoding: utf-8
require 'spec_helper'
require 'tmpdir'

module Machete
  module CF
    describe PushApp do
      let(:src_directory) { Dir.mktmpdir }
      let(:app) do
        double(:app, name: 'app_name',
                     src_directory: src_directory,
                     start_command: start_command,
                     stack: stack,
                     buildpack: buildpack)
      end
      let(:start_command) { nil }
      let(:stack) { nil }
      let(:buildpack) { nil }

      subject(:push_app) { PushApp.new }

      before do
        allow(SystemHelper).to receive(:run_cmd)
      end

      context 'default arguments' do
        specify do
          expect(SystemHelper).to receive(:run_cmd).with("cf push app_name -p #{src_directory}")
          push_app.execute(app)
        end
      end

      context 'start argument is false' do
        specify do
          expect(SystemHelper).to receive(:run_cmd).with("cf push app_name -p #{src_directory} --no-start")
          push_app.execute(app, start: false)
        end
      end

      context 'app has start command' do
        let(:start_command) { 'start_command' }

        specify do
          expect(SystemHelper).to receive(:run_cmd).with("cf push app_name -p #{src_directory} -c 'start_command'")
          push_app.execute(app)
        end
      end

      context 'app has a stack' do
        let(:stack) { 'stack' }

        specify do
          expect(SystemHelper).to receive(:run_cmd).with("cf push app_name -p #{src_directory} -s stack")
          push_app.execute(app)
        end
      end

      context 'app has a buildpack' do
        let(:buildpack) { 'my_buildpack' }

        specify do
          expect(SystemHelper).to receive(:run_cmd).with("cf push app_name -p #{src_directory} -b my_buildpack")
          push_app.execute(app)
        end
      end

      context 'app has a manifest.yml' do
        specify do
          FileUtils.touch(File.join(src_directory, 'manifest.yml'))
          expect(SystemHelper).to receive(:run_cmd).with("cf push app_name -p #{src_directory} -f #{src_directory}/manifest.yml")
          push_app.execute(app)
        end
      end
    end
  end
end
