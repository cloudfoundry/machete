require 'spec_helper'

module Machete::Host
  describe Aws::DB do
    let(:host) { double(:host) }
    subject(:host_db) { Aws::DB.new(host) }

    describe '#run' do
      it 'gets results from psql' do
        expect(host).to receive(:run)
          .with('export PATH=/var/vcap/packages/postgres/bin:$PATH; psql my_command', :postgres_z1)
          .and_return('psql output')

        expect(host_db.run('psql my_command')).to eq 'psql output'
      end
    end

    describe '#hostname' do
      context 'when bosh includes the vm postgres_zl' do
        it 'returns the IP address for the VM' do
          expect(Machete::SystemHelper).to receive(:run_cmd).with('bosh vms').and_return(<<-BOSH_OUTPUT)
| nfs_z1/0                           | running | small_z1      | 10.0.16.105    |
| postgres_z1/0                      | running | small_z1      | 10.0.16.101    |
          BOSH_OUTPUT

          expect(host_db.hostname).to eq '10.0.16.101'
        end
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

