require './spec/spec_helper'
require 'machete'

describe Machete::AppController do
  subject(:app_controller) { Machete::AppController.new('path/app_name') }

  before do
    allow_any_instance_of(Machete::SystemHelper).to receive(:run_on_host)
  end

  describe '#cf_internet_log' do
    let(:log_entry) { double(:log_entry) }

    before do
      allow_any_instance_of(Machete::SystemHelper).to receive(:run_on_host).
                                                        with('sudo cat /var/log/internet_access.log').
                                                        and_return(log_entry)
    end

    specify do
      expect(app_controller.cf_internet_log).to eql log_entry
      expect(app_controller).to have_received(:run_on_host).with('sudo cat /var/log/internet_access.log')
    end
  end

  describe '#initialize' do
    let(:app) { double }
    let(:fixture) { double }

    before do
      allow(Machete::App).to receive(:new).and_return(app)
      allow(Machete::Fixture).to receive(:new).and_return(fixture)
      app_controller
    end

    context 'intialize the app' do
      specify do
        expect(app_controller.app).to eql app
      end

      specify do
        expect(Machete::App).to have_received(:new).with('app_name')
      end
    end

    context 'intialize the fixture' do
      specify do
        expect(app_controller.fixture).to eql fixture
      end

      specify do
        expect(Machete::Fixture).to have_received(:new).with('path/app_name')
      end
    end
  end

  describe '#homepage_html' do
    before(:each) do
      allow(app_controller.app).to receive(:homepage_body).and_return('the app body')
    end

    specify do
      expect(app_controller.homepage_html).to eql 'the app body'
    end
  end

  describe '#logs' do
    before(:each) do
      allow(app_controller.app).to receive(:logs).and_return('some logging')
    end

    specify do
      expect(app_controller.logs).to eql 'some logging'
    end
  end

  describe '#push' do
    before do
      allow(Dir).to receive(:chdir).and_yield
      allow(app_controller).to receive(:run_cmd).and_return("")
      allow(Machete).to receive(:logger).and_return(double.as_null_object)
      allow(Wait).to receive(:until_true!)

      allow(app_controller.app).to receive(:delete)
      allow(app_controller.app).to receive(:push)
    end

    context 'clearing internet access log' do
      before do
        allow(app_controller).to receive(:run_on_host)
      end

      specify do
        app_controller.push

        expect(app_controller).
          to have_received(:run_on_host).
               ordered.
               with('sudo rm /var/log/internet_access.log')

        expect(app_controller).
          to have_received(:run_on_host).
               ordered.
               with('sudo restart rsyslog')

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
      let(:app_controller) { Machete::AppController.new('path/app_name', options) }
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

          expect(app_controller).
            to have_received(:run_cmd).
                 with('cf set-env app_name MY_ENV_VAR true').
                 ordered

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
          allow(app_controller).to receive(:run_cmd).with('cf api').and_return('api.1.1.1.1.xip.io')
        end

        context 'with default database name' do
          specify do
            app_controller.push

            expect(app_controller.app).to have_received(:delete).ordered
            expect(app_controller.app).to have_received(:push).with(start: false).ordered

            expect(app_controller).
              to have_received(:run_cmd).
                   with('cf set-env app_name DATABASE_URL postgres://buildpacks:buildpacks@1.1.1.30:5524/buildpacks').
                   ordered

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
            expect(app_controller).to have_received(:run_cmd).with('cf set-env app_name DATABASE_URL postgres://buildpacks:buildpacks@1.1.1.30:5524/wordpress')
          end
        end
      end

      context 'waiting for the instance to start' do
        before do
          allow(app_controller).
            to receive(:run_cmd).
                 with('cf curl /v2/apps?q=\'name:app_name\'', true).
                 and_return('{
                  "total_results": 1,
                  "resources": [
                      {
                          "metadata": {
                              "url": "/v2/apps/app_url"
                          }
                      }
                  ]
              }')
          allow(app_controller).
            to receive(:run_cmd).
                 with('cf curl /v2/apps/app_url/summary', true).
                 and_return('{"running_instances":1}')

          allow(Wait).to receive(:until_true!).and_yield
        end

        specify do
          app_controller.push
          expect(Wait).to have_received(:until_true!).with('instance started', timeout_in_seconds: 30)
        end
      end
    end
  end

  describe '#number_of_running_instances' do
    let(:app_resource_url) { '/v2/apps/app_url' }

    before do
      allow(app_controller).
        to receive(:run_cmd).
             with('cf curl /v2/apps?q=\'name:app_name\'', true).
             and_return('{
                  "total_results": 1,
                  "resources": [
                      {
                          "metadata": {
                              "url": "' + app_resource_url + '"
                          }
                      }
                  ]
              }')
      allow(app_controller).
        to receive(:run_cmd).
             with('cf curl ' + app_resource_url + '/summary', true).
             and_return('{"running_instances":3}')
    end

    it 'returns the number_of_instances' do
      expect(app_controller.number_of_running_instances).to eql 3
    end
  end
end