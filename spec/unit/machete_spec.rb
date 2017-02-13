# encoding: utf-8
require 'spec_helper'
require 'tmpdir'

describe Machete do
  let(:app_deployer) { double(:app_deployer) }
  let(:path) { 'path/to\~\>/app_name' }
  let(:app) { Machete::App.new(path, options) }
  let(:options) { {} }

  before do
    @current_dir = Dir.pwd
    @temp_dir = Dir.mktmpdir
    @old_buildpack_version = ENV['BUILDPACK_VERSION']
    ENV['BUILDPACK_VERSION'] = '99-12345'

    Dir.chdir(@temp_dir)
    FileUtils.mkdir_p(File.join('cf_spec', 'fixtures', 'path/to~>/app_name'))

    directory_with_file = File.join('cf_spec', 'fixtures', 'path/exists')
    FileUtils.mkdir_p(directory_with_file)
    File.write(File.join(directory_with_file, 'java.jar'), '')

    allow(Machete::DeployApp)
      .to receive(:new)
      .with(no_args)
      .and_return app_deployer
  end

  after do
    Dir.chdir(@current_dir)
    FileUtils.rm_rf(@temp_dir)
    ENV['BUILDPACK_VERSION'] = @old_buildpack_version
  end

  describe '#deploy_app' do
    before do
      allow(app_deployer)
        .to receive(:execute)
        .with(app)

      allow(Machete::App)
        .to receive(:new)
        .with(path, options)
        .and_return(app)
    end

    context 'the app path is incorrect' do
      context 'the app path is not escaped' do
        let(:path) { 'path/does/not/exist' }

        it 'throws an exception' do
          expect { described_class.deploy_app(path) }.to raise_error(RuntimeError)
        end
      end

      context 'the app path is escaped' do
        let(:path) { 'path/contains/\~\>/operator' }

        it 'throws an exception' do
          expect { described_class.deploy_app(path) }.to raise_error(RuntimeError)
        end
      end
    end

    context 'the app path is a single file like a .jar for java' do
      let(:path) { 'path/exists/java.jar' }

      specify do
        expect(described_class).to receive(:verify_buildpack_version).with(app)
        result = described_class.deploy_app(path)
        expect(result).to eql app
        expect(app_deployer).to have_received(:execute)
      end
    end

    context 'no additional options' do
      specify do
        expect(described_class).to receive(:verify_buildpack_version).with(app)
        result = described_class.deploy_app(path)
        expect(result).to eql app
        expect(app_deployer).to have_received(:execute)
      end
    end

    context 'with additional options' do
      let(:options) { {buildpack: 'fake-buildpack', stack: 'cflinux99', skip_verify_version: true} }

      specify do
        expect(described_class).not_to receive(:verify_buildpack_version)
        result = described_class.deploy_app(path, options)
        expect(result).to eql app
        expect(result.stack).to eql 'cflinux99'
        expect(result.buildpack).to eql 'fake-buildpack'
        expect(app_deployer).to have_received(:execute)
      end
    end
  end

  describe '.push' do
    before do
      allow(app_deployer)
        .to receive(:execute)
        .with(app, push_only: true)
    end

    specify do
      described_class.push(app)
      expect(app_deployer).to have_received(:execute).with(app, push_only: true)
    end
  end
end
