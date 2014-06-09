require './spec/spec_helper'
require 'machete/app'

describe Machete::App do

  before do
    allow_any_instance_of(Machete::SystemHelper).to receive(:run_on_host)
  end

  context "when using a database" do
    let(:app) { Machete::App.new('path/app_name', with_pg: true) }

    before do
      allow(Machete).to receive(:logger).and_return(double.as_null_object)

      # capture all run_cmd arguments for easier debugging
      @run_commands = []
      allow_any_instance_of(Machete::SystemHelper).to receive(:run_cmd) do |_, *ary|
        @run_commands.push ary.first
        case (ary.first)
          when 'cf api'
            'api.1.2.3.4.xip.io'
          else
            ""
        end

      end

      allow_any_instance_of(Machete::App).to receive(:generate_manifest).and_return(nil)
      allow(Dir).to receive(:chdir).and_yield

      app.push
    end

    it "runs every command once" do
      expect(@run_commands.uniq).to eq(@run_commands)
    end

    it "pushes the app without starting it" do
      expect(@run_commands).to include("cf push app_name --no-start")
    end

    it "sets the DATABASE_URL environment variable with default DB" do
      expect(@run_commands).to include("cf set-env app_name DATABASE_URL postgres://buildpacks:buildpacks@1.2.3.30:5524/buildpacks")
    end

    it "pushes the app once" do
      expect(@run_commands).to include("cf push app_name")
    end

    describe "specifying a different database" do
      let(:app) { Machete::App.new('path/app_name', with_pg: true, database_name: "wordpress") }

      it "sets the DATABASE_URL environment variable with default DB" do
        expect(app).to have_received(:run_cmd).with("cf set-env app_name DATABASE_URL postgres://buildpacks:buildpacks@1.2.3.30:5524/wordpress")
      end
    end

    describe 'access the cf internet log' do
      let(:log_entry) { double(:log_entry) }
      let(:app) { Machete::App.new('path/app_name') }

      before do
        allow_any_instance_of(Machete::SystemHelper).to receive(:run_on_host).
                                                          with("sudo cat /var/log/internet_access.log").
                                                          and_return(log_entry)
      end

      specify do
        expect(app.cf_internet_log).to eql log_entry
        expect(app).to have_received(:run_on_host).with("sudo cat /var/log/internet_access.log")
      end
    end
  end

  describe "pushing an app" do
    let(:app) { Machete::App.new('path/app_name') }

    before do
      allow(Machete).to receive(:logger).and_return(double.as_null_object)
      allow(app).to receive(:run_on_host)
      allow(app).to receive(:run_cmd).and_return("")
      allow(Dir).to receive(:chdir).and_yield

      app.push
    end

    it "clears the internet access log before pushing the app" do
      expect(app).to have_received(:run_on_host).
                       ordered.
                       with("sudo rm /var/log/internet_access.log")

      expect(app).to have_received(:run_on_host).
                       ordered.
                       with("sudo restart rsyslog")

      expect(app).to have_received(:run_cmd).
                        with("cf delete -f app_name").
                       ordered
    end
  end
end