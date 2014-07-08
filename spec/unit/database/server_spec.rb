require 'spec_helper'

module Machete
  class Database
    describe Server do
      subject(:server) { Server.new }

      describe '#host' do
        let(:cf_api) { double(:cf_api) }

        before do
          allow(CF::API).
            to receive(:new).
                 and_return(cf_api)

          allow(cf_api).
            to receive(:execute).
                 with(no_args).
                 and_return('API endpoint: https://api.192.0.2.34.xip.io (API version: 2.6.0)')
        end

        specify do
          expect(server.host).to eql '192.0.2.30'
        end
      end
    end
  end
end
