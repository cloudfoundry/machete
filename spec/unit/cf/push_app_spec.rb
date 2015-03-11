require 'spec_helper'

module Machete
  module CF
    describe PushApp do
      let(:app) do
        double(:app, name: 'app_name',
               src_directory: 'path/to/src', 
               start_command: start_command, 
               stack: stack, 
               buildpack: buildpack)
      end
      let(:start_command) { nil }
      let(:stack) { nil }
      let(:buildpack) { nil }

      subject(:push_app) { PushApp.new }

      before do
        allow(Dir).
          to receive(:chdir).
               with('path/to/src').
               and_yield
      end

      context 'default arguments' do
        before do
          allow(SystemHelper).to receive(:run_cmd)
        end

        specify do
          expect(SystemHelper).to receive(:run_cmd).with('cf push app_name')
          expect(Dir).to receive(:chdir)
          push_app.execute(app)
        end
      end

      context 'start argument is false' do
        before do
          allow(SystemHelper).to receive(:run_cmd)
        end

        specify do
          expect(SystemHelper).to receive(:run_cmd).with('cf push app_name --no-start')
          expect(Dir).to receive(:chdir)
          push_app.execute(app, start: false)
        end
      end

      context 'app has start command' do
        let(:start_command) { 'start_command' }

        before do
          allow(SystemHelper).to receive(:run_cmd)
        end

        specify do
          expect(SystemHelper).to receive(:run_cmd).with('cf push app_name -c \'start_command\'')
          push_app.execute(app)
        end
      end

      context 'app has a stack' do
        let(:stack) { 'stack' }

        before do
          allow(SystemHelper).to receive(:run_cmd)
        end

        specify do
          expect(SystemHelper).to receive(:run_cmd).with('cf push app_name -s stack')
          push_app.execute(app)
        end
      end

      context 'app has a buildpack' do
        let(:buildpack) { 'my_buildpack' }

        before do
          allow(SystemHelper).to receive(:run_cmd)
        end

        specify do
          expect(SystemHelper).to receive(:run_cmd).with('cf push app_name -b my_buildpack')
          push_app.execute(app)
        end
      end
    end
  end
end
