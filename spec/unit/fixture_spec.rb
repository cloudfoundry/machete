require 'spec_helper'

module Machete
  describe Fixture do
    subject(:fixture) { Fixture.new('path/to/kyle_has_an_awesome_app') }

    describe '#directory' do
      specify do
        expect(fixture.directory).to eql 'cf_spec/fixtures/path/to/kyle_has_an_awesome_app'
      end
    end

    describe '#vendor' do
      before do
        allow(Machete.logger).to receive(:action)
        allow(Bundler).to receive(:with_clean_env).and_yield
        allow(SystemHelper).to receive(:run_cmd)
      end

      context 'when there is no script' do
        before do
          allow(File).to receive(:exist?).with('package.sh').and_return(false)
          fixture.vendor
        end

        specify do
          expect(Machete.logger).not_to have_received(:action).with('Vendoring dependencies before push')
        end

        specify do
          expect(SystemHelper).not_to have_received(:run_cmd).with('./package.sh')
        end

        specify do
          expect(SystemHelper).not_to have_received(:run_cmd)
        end
      end

      context 'when there is a script' do
        before do
          allow(File).to receive(:exist?).with('package.sh').and_return(true)
          fixture.vendor
        end

        specify do
          expect(Machete.logger).to have_received(:action).with('Vendoring dependencies before push')
        end

        specify do
          expect(Bundler).to have_received(:with_clean_env)
        end

        specify do
          expect(SystemHelper).to have_received(:run_cmd).with('./package.sh')
        end
      end
    end
  end
end