# encoding: utf-8
require_relative '../spec_helper'
require 'machete/matchers'

module Machete
  describe '#have_logged' do
    let(:fixture_dir) { File.join(Dir.pwd, 'spec', 'integration', 'matchers',
                                  'have_logged') }

    subject(:app) do
      Machete.deploy_app(app_name, { name: app_name, buildpack: 'null-test-buildpack'})
    end

    before do
      Dir.chdir(fixture_dir) do
        Bundler.with_clean_env do
          system('BUNDLE_GEMFILE=cf.Gemfile bundle && BUNDLE_GEMFILE=cf.Gemfile bundle exec buildpack-packager --cached')
          system('cf create-buildpack null-test-buildpack null_buildpack-cached-v0.0.1.zip 1')
        end
      end
    end

    after do
      Machete::CF::DeleteApp.new.execute(app)
      system('cf delete-buildpack -f null-test-buildpack')
    end

    context 'an app that outputs logs' do
      let(:app_name) { 'app_that_logs_noise' }
      let(:browser) { Machete::Browser.new(app) }

      it 'logs one of the first lines of staging output' do
        Dir.chdir(fixture_dir) do
          expect(app).to have_logged("Start of logs")
        end
      end

      it 'logs one of the last lines of staging output' do
        Dir.chdir(fixture_dir) do
          expect(app).to have_logged("Log line 150")
        end
      end

      it 'logs lines after app push' do
        Dir.chdir(fixture_dir) do
          expect(app).to have_logged("Start of logs")
          expect(app).to be_running

          browser.visit_path('/non-existent-path')
          expect(app).to have_logged("/non-existent-path' not found")
        end
      end

      it 'does not incorrectly log content' do
        Dir.chdir(fixture_dir) do
          expect(app).to_not have_logged("Random line that should not be there")
        end
      end
    end
  end
end
