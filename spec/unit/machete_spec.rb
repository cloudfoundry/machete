require 'spec_helper'

describe Machete do
  let(:app) { double(:app) }
  let(:deploy_app) { double(:deploy_app) }

  before do
    allow(Machete::DeployApp).
      to receive(:new).
           with(no_args).
           and_return deploy_app
  end

  describe '.deploy_app' do
    let(:path) { 'path/to/app_name' }
    let(:host) { double(:host) }

    before do
      allow(Machete::Host).
        to receive(:new).
             and_return(host)

      allow(deploy_app).
        to receive(:execute).
             with(app)
    end

    context 'no additional options' do
      before do
        allow(Machete::App).
          to receive(:new).
               with(path, host, {}).
               and_return(app)
      end

      specify do
        result = Machete.deploy_app('path/to/app_name')
        expect(result).to eql app
        expect(deploy_app).to have_received(:execute)
      end
    end

    context 'with additional options' do
      let(:options) { double(:options) }

      before do
        allow(Machete::App).
          to receive(:new).
               with(path, host, options).
               and_return(app)
      end

      specify do
        result = Machete.deploy_app('path/to/app_name', options)
        expect(result).to eql app
        expect(deploy_app).to have_received(:execute)
      end
    end
  end

  describe '.push' do
    before do
      allow(deploy_app).
        to receive(:execute).
             with(app, push_only: true)
    end

    specify do
      Machete.push(app)
      expect(deploy_app).to have_received(:execute).with(app, push_only: true)
    end
  end
end
