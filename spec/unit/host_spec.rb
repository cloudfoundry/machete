require 'spec_helper'

module Machete
  describe Host do

    subject(:host) { Host.new }

    context 'when VAGRANT_CWD is set' do
      before do
        ENV['VAGRANT_CWD'] = 'true'

        allow(Bundler).
          to receive(:with_clean_env).
               and_yield

        allow(host).
          to receive(:`).
               with('vagrant ssh -c \'command\' 2>&1').
               and_return 'hello there'
      end

      specify do
        expect(host.run('command')).to eql 'hello there'
      end
    end

    context 'when VAGRANT_CWD is not set' do
      before do
        ENV['VAGRANT_CWD'] = nil
      end

      specify do
        expect do
          host.run('command')
        end.to raise_error(VagrantCWDMissingError)
      end
    end
  end
end
