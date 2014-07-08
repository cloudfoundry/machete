require 'spec_helper'

module Machete
  describe DeployApp do
    let(:app_needs_setup?) { false }
    let(:app) do
      double(:app,
             path: path,
             host: host,
             name: 'app_name',
             needs_setup?: app_needs_setup?
      )
    end

    let(:vendor_dependencies) { double(:vendor_dependencies) }
    let(:host) { double(:host, run: '') }
    let(:logger) { double(:logger) }
    let(:delete_app) { double(:delete_app) }
    let(:push_app) { double(:push_app) }
    let(:setup_app) { double(:setup_app) }
    let(:path) { 'path/app_name' }

    subject(:deploy_app) { DeployApp.new }

    describe '#execute' do
      let(:host_log) { double(:host_log, clear: true) }

      before do
        allow(VendorDependencies).
          to receive(:new).
               and_return(vendor_dependencies)

        allow(vendor_dependencies).
          to receive(:execute).
               with(app)

        allow(Host::Log).
          to receive(:new).
               with(host).
               and_return host_log

        allow(CF::DeleteApp).
          to receive(:new).
               and_return(delete_app)

        allow(delete_app).
          to receive(:execute).
               with(app)

        allow(CF::PushApp).
          to receive(:new).
               and_return(push_app)

        allow(push_app).
          to receive(:execute).
               with(app)

        allow(SetupApp).
          to receive(:new).
               and_return(setup_app)

        allow(setup_app).
          to receive(:execute).
               with(app)
      end

      context 'clearing internet access log' do
        specify do
          deploy_app.execute(app)
          expect(host_log).to have_received(:clear).ordered
          expect(push_app).to have_received(:execute).ordered
        end
      end

      context 'vendoring' do
        specify do
          deploy_app.execute(app)
          expect(vendor_dependencies).to have_received(:execute).ordered
          expect(push_app).to have_received(:execute).ordered
        end
      end

      context 'deletes the app first' do
        specify do
          deploy_app.execute(app)
          expect(delete_app).to have_received(:execute).ordered
          expect(push_app).to have_received(:execute).ordered
        end
      end

      context 'app needs setup' do
        let(:app_needs_setup?) { true }

        before do
          allow(push_app).
            to receive(:execute).
                 with(app, start: false)
        end

        specify do
          deploy_app.execute(app)

          expect(delete_app).to have_received(:execute).with(app).ordered
          expect(push_app).to have_received(:execute).with(app, start: false).ordered
          expect(setup_app).to have_received(:execute).with(app).ordered

          expect(push_app).to have_received(:execute).with(app).ordered
        end
      end

      context 'with no environment variables set' do
        specify do
          deploy_app.execute(app)
          expect(push_app).to have_received(:execute).once
          expect(push_app).to have_received(:execute).with(app)
        end
      end
    end
  end
end
