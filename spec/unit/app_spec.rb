require './spec/spec_helper'
require 'machete/app'

describe Machete::App do
  subject(:app) { Machete::App.new('kyle_has_an_awesome_app') }

  before do
    allow(app).to receive(:run_cmd)
  end

  describe 'SystemHelper' do
    specify do
      expect(Machete::App.method_defined?(:run_cmd)).to be_truthy
    end
  end

  describe '#push' do
    context 'starting the app immediately' do
      before do
        app.push
      end

      specify do
        expect(app).to have_received(:run_cmd).with('cf push kyle_has_an_awesome_app')
      end
    end

    context 'not starting the app immediately' do
      before do
        app.push(start: false)
      end

      specify do
        expect(app).to have_received(:run_cmd).with('cf push kyle_has_an_awesome_app --no-start')
      end
    end
  end

  describe '#delete' do
    before do
      app.delete
    end

    specify do
      expect(app).to have_received(:run_cmd).with('cf delete -f kyle_has_an_awesome_app')
    end
  end

  describe '#homepage_body' do
    let(:website) { double(body: 'kyles homepage body') }

    before do
      allow(app).to receive(:run_cmd).with('cf app kyle_has_an_awesome_app | grep url').and_return('urls: www.kylesurl.com')
      allow(HTTParty).to receive(:get).with('http://www.kylesurl.com').and_return website
    end

    specify do
      expect(app.homepage_body).to eql 'kyles homepage body'
    end
  end

  describe '#logs' do
    before do
      allow(app).to receive(:run_cmd).with('cf logs kyle_has_an_awesome_app --recent').and_return('some logging')
    end

    specify do
      expect(app.logs).to eql 'some logging'
    end
  end

  describe '#file' do
    before do
      allow(app).to receive(:run_cmd).with('cf files kyle_has_an_awesome_app log/a_log_file.log').and_return('output from file')
    end

    specify do
      expect(app.file('log/a_log_file.log')).to eql 'output from file'
    end
  end

  describe '#has_file' do
    before do
      allow(app).to receive(:run_cmd).with('cf files kyle_has_an_awesome_app log/a_log_file.log')
    end

    context 'the file exists' do
      let(:app_has_file) { app.has_file?('log/a_log_file.log') }

      before do
        allow($?).to receive(:exitstatus).and_return(0)
      end

      specify do
        expect(app_has_file).to be_truthy
      end

      specify do
        app_has_file
        expect(app).to have_received(:run_cmd).with('cf files kyle_has_an_awesome_app log/a_log_file.log')
      end
    end

    context 'the file does not exist' do
      let(:app_has_file) { app.has_file?('log/a_log_file.log') }

      before do
        allow($?).to receive(:exitstatus).and_return(1)
      end

      specify do
        expect(app_has_file).to be_falsey
      end

      specify do
        app_has_file
        expect(app).to have_received(:run_cmd).with('cf files kyle_has_an_awesome_app log/a_log_file.log')
      end
    end
  end
end