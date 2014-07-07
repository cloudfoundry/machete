require 'spec_helper'

module Machete
  describe DatabaseUrlBuilder do
    describe do
      let(:cf_api) { double(:cf_api) }
      subject(:database_url_builder) { DatabaseUrlBuilder.new }

      context 'default database name' do
        let(:database_url) { 'postgres://buildpacks:buildpacks@192.0.2.30:5524/buildpacks' }

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
          expect(database_url_builder.execute()).to eql database_url
        end
      end

      context 'supplied database name' do
        let(:database_name) { 'database_name' }
        let(:database_url) { 'postgres://buildpacks:buildpacks@192.0.2.30:5524/database_name' }

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
          expect(database_url_builder.execute(database_name: database_name)).to eql database_url
        end
      end
    end
  end
end
