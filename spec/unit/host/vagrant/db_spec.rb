require 'spec_helper'

module Machete::Host
  describe Vagrant::DB do
    let(:host) { double(:host) }
    subject(:host_db) { Vagrant::DB.new(host) }

    describe '#run' do
      it 'gets results from psql' do
        expect(Machete::SystemHelper).to receive(:run_cmd)
          .with('psql my_command')
          .and_return('psql output')

        expect(host_db.run('psql my_command')).to eq 'psql output'
      end
    end

    describe '#hostname' do
      let(:cf_api) { double(:cf_api) }

      before do
        allow(Machete::CF::API).
            to receive(:new).
                   and_return(cf_api)

        allow(cf_api).
            to receive(:execute).
                   with(no_args).
                   and_return('API endpoint: https://api.192.0.2.34.xip.io (API version: 2.6.0)')
      end

      specify do
        expect(host_db.hostname).to eql '192.0.2.30'
      end
    end

    describe '#port' do
      it { expect(host_db.port).to eq 5524 }
    end

    describe '#type' do
      it { expect(host_db.type).to eq 'postgres' }
    end
  end
end

