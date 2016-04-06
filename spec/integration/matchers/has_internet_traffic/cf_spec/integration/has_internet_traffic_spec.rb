# encoding: utf-8
require_relative '../spec_helper'
require 'machete/matchers'

module Machete
  describe '#has_internet_traffic' do
    let(:fixture_dir) { File.join(Dir.pwd, 'spec', 'integration', 'matchers',
                                  'has_internet_traffic') }

    subject(:app) do
      Machete::App.new(app_name, { name: app_name, buildpack: 'null-test-buildpack'} )
    end

    before do
      Dir.chdir(fixture_dir) do
        system('BUNDLE_GEMFILE=cf.Gemfile bundle && BUNDLE_GEMFILE=cf.Gemfile bundle exec buildpack-packager --cached')
      end
    end

    context 'an app that does not access the internet' do
      let(:app_name) { 'app_that_does_not_access_the_internet' }

      it 'logs no internet traffic' do
        Dir.chdir(fixture_dir) do
          expect(app).not_to have_internet_traffic
        end
      end
    end

    context 'an app that accesses the internet' do
      let(:app_name)    { 'app_that_accesses_the_internet' }

      it 'logs internet traffic' do
        Dir.chdir(fixture_dir) do
          expect(app).to have_internet_traffic
        end
      end
    end
  end
end
