require 'spec_helper'

module Machete
  describe Host::Vagrant do

    subject(:host) { Host::Vagrant.new(vagrant_cwd) }

    let(:vagrant_cwd) { nil }

    describe '#create_log_manager' do
      let(:log_manager) { double(:log_manager) }

      before do
        allow(Host::Vagrant::Log).to receive(:new).
                                       with(host).
                                       and_return(log_manager)
      end

      specify do
        expect(host.create_log_manager).to eql(log_manager)
      end
    end

    describe '#create_db_manager' do
      let(:db_manager) { double(:db_manager) }

      before do
        allow(Host::Vagrant::DB).to receive(:new).
                                       with(host).
                                       and_return(db_manager)
      end

      specify do
        expect(host.create_db_manager).to eql(db_manager)
      end
    end

    describe '#run' do
      context 'when VAGRANT_CWD is set' do
        let(:vagrant_cwd) { '/tmp' }

        before do
          allow(Bundler).
            to receive(:with_clean_env).
            and_yield

          allow(SystemHelper).
            to receive(:run_cmd).
            with('vagrant ssh -c \'command\' 2>&1').
            and_return 'hello there'
        end

        specify do
          expect(host.run('command')).to eql 'hello there'
        end
      end

      context 'when VAGRANT_CWD is not set' do
        specify do
          expect do
            host.run('command')
          end.to raise_error(Host::VagrantCWDMissingError)
        end
      end
    end
  end
end
