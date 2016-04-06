# encoding: utf-8
require_relative '../spec_helper'
require 'machete/matchers'

module Machete
  describe '#uses_proxy_during_staging' do
    let(:fixture_dir) { File.join(Dir.pwd, 'spec', 'integration', 'matchers',
                                  'uses_proxy_during_staging') }

    subject(:app) do
      Machete::App.new(app_name, { name: app_name, buildpack: 'null-test-buildpack'} )
    end

    before do
      Dir.chdir(fixture_dir) do
        system('BUNDLE_GEMFILE=cf.Gemfile bundle && BUNDLE_GEMFILE=cf.Gemfile bundle exec buildpack-packager --uncached')
      end
    end

    context 'a buildpack that utilizes proxies correctly' do
      let(:app_name) { 'app_that_causes_correct_staging_proxy_use' }

      it 'uses the proxy correctly during staging' do
        Dir.chdir(fixture_dir) do
          expect(app).to use_proxy_during_staging
        end
      end
    end

    context 'a buildpack that utilizes proxies incorrectly' do
      let(:app_name) { 'app_that_causes_incorrect_staging_proxy_use' }

      it 'does not use the proxy during staging' do
        Dir.chdir(fixture_dir) do
          expect(app).to_not use_proxy_during_staging
        end
      end
    end
  end
end
