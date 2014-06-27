require 'spec_helper'

module Machete
  describe AppController do
    let(:app) { double(:app, path: path, host: host, name: 'app_name') }
    let(:fixture) { double(:fixture, directory: 'a_directory', vendor: true) }
    let(:host) { double(:host, run: '') }
    let(:logger) { double(:logger) }

    let(:path) { 'path/app_name' }

    subject(:app_controller) { AppController.new(app) }

    before do
      allow_any_instance_of(SystemHelper).to receive(:run_on_host)
    end

    describe '#push' do
      let(:host_log) { double(:host_log, clear: true) }

      before do
        allow(Dir).to receive(:chdir).and_yield
        allow(Machete).to receive(:logger).and_return(logger)

        allow(Fixture).to receive(:new).and_return(fixture)

        allow(Host::Log).to receive(:new).with(host).and_return host_log
        allow(app).to receive(:delete)
        allow(app).to receive(:push)
        allow(app).to receive(:set_env)
      end

      context 'clearing internet access log' do
        specify do
          app_controller.push
          expect(host_log).to have_received(:clear).ordered
          expect(app).to have_received(:delete).ordered
        end
      end

      context 'vendoring' do
        before do
          allow(fixture).to receive(:vendor)
          app_controller.push
        end

        specify do
          expect(fixture).to have_received(:vendor)
        end
      end

      context 'changing to fixture directory' do
        before do
          allow(fixture).to receive(:directory).and_return('a_directory')
          app_controller.push
        end

        specify do
          expect(Dir).to have_received(:chdir).with('a_directory')
        end
      end

      context 'options' do
        let(:app_controller) { AppController.new(app, options) }
        let(:options) do
          {}
        end

        context 'setting environment variables' do
          let(:options) do
            {
              env: {
                MY_ENV_VAR: 'true'
              }
            }
          end

          specify do
            app_controller.push

            expect(app).to have_received(:delete).ordered
            expect(app).to have_received(:push).with(start: false).ordered
            expect(app).to have_received(:set_env).with('MY_ENV_VAR', 'true').ordered
            expect(app).to have_received(:push).with(no_args).ordered
          end
        end

        context 'with no environment varaibles set' do
          specify do
            app_controller.push

            expect(app).to have_received(:push).once
            expect(app).to have_received(:push).with(no_args)
          end
        end

        context 'enabling postgres database' do
          let(:options) do
            {
              with_pg: true
            }
          end

          before do
            allow(SystemHelper).to receive(:run_cmd).with('cf api').and_return('api.1.1.1.1.xip.io')
          end

          context 'with default database name' do
            specify do
              app_controller.push

              expect(app).to have_received(:delete).ordered
              expect(app).to have_received(:push).with(start: false).ordered
              expect(app).to have_received(:set_env).
                               with('DATABASE_URL', 'postgres://buildpacks:buildpacks@1.1.1.30:5524/buildpacks').ordered
              expect(app).to have_received(:push).with(no_args).ordered
            end
          end

          context 'with database name provided' do
            let(:options) do
              {
                with_pg: true,
                database_name: 'wordpress'
              }
            end

            specify do
              app_controller.push
              expect(app).to have_received(:set_env).
                               with('DATABASE_URL', 'postgres://buildpacks:buildpacks@1.1.1.30:5524/wordpress')
            end
          end
        end
      end
    end
  end
end