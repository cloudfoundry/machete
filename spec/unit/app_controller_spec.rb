require 'spec_helper'

module Machete
  describe AppController do
    subject(:app_controller) { AppController.new(app) }
    let(:app) { double(:app, path: path, host: host, name: 'app_name')}
    let(:host) { double(:host, run: '') }
    let(:path) { 'path/app_name' }

    before do
      allow_any_instance_of(SystemHelper).to receive(:run_on_host)
    end

    describe '#initialize' do
      let(:fixture) { double }

      before do
        allow(Fixture).to receive(:new).and_return(fixture)
        app_controller
      end

      context 'intialize the fixture' do
        specify do
          expect(app_controller.fixture).to eql fixture
        end

        specify do
          expect(Fixture).to have_received(:new).with('path/app_name')
        end
      end
    end

    describe '#has_file?' do
      let(:has_file) { double }

      before(:each) do
        allow(app_controller.app).to receive(:has_file?).with('a_file').and_return(has_file)
      end

      specify do
        expect(app_controller.has_file?('a_file')).to eql has_file
      end
    end

    describe '#staging_log' do
      before(:each) do
        allow(app_controller.app).to receive(:file).and_return('a string')
      end

      specify do
        expect(app_controller.staging_log).to eql 'a string'
      end
    end

    describe '#push' do
      let(:host_log) { double(:host_log, clear: true) }

      before do
        allow(Dir).to receive(:chdir).and_yield
        allow(Machete).to receive(:logger).and_return(double.as_null_object)

        allow(Host::Log).to receive(:new).with(host).and_return host_log
        allow(app_controller.app).to receive(:delete)
        allow(app_controller.app).to receive(:push)
        allow(app_controller.app).to receive(:set_env)
      end

      context 'clearing internet access log' do
        specify do
          app_controller.push
          expect(host_log).to have_received(:clear).ordered
          expect(app_controller.app).to have_received(:delete).ordered
        end
      end

      context 'vendoring' do
        before do
          allow(app_controller.fixture).to receive(:vendor)
          app_controller.push
        end

        specify do
          expect(app_controller.fixture).to have_received(:vendor)
        end
      end

      context 'changing to fixture directory' do
        before do
          allow(app_controller.fixture).to receive(:directory).and_return('a_directory')
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

            expect(app_controller.app).to have_received(:delete).ordered
            expect(app_controller.app).to have_received(:push).with(start: false).ordered
            expect(app_controller.app).to have_received(:set_env).with('MY_ENV_VAR', 'true').ordered
            expect(app_controller.app).to have_received(:push).with(no_args).ordered
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

              expect(app_controller.app).to have_received(:delete).ordered
              expect(app_controller.app).to have_received(:push).with(start: false).ordered
              expect(app_controller.app).to have_received(:set_env).
                                              with('DATABASE_URL', 'postgres://buildpacks:buildpacks@1.1.1.30:5524/buildpacks').ordered
              expect(app_controller.app).to have_received(:push).with(no_args).ordered
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
              expect(app_controller.app).to have_received(:set_env).
                                              with('DATABASE_URL', 'postgres://buildpacks:buildpacks@1.1.1.30:5524/wordpress')
            end
          end
        end
      end
    end
  end
end