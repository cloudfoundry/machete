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
        allow(File).to receive(:exist?).with('package.sh').and_return(package_script_exists)
        fixture.vendor
      end

      context 'when there is no script' do
        let(:package_script_exists) { false }

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
        let(:package_script_exists) { true }

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

      describe 'exit status' do
        let(:package_script_exists) { true }

        before do
          allow(SystemHelper).to receive(:exit_status).and_return exit_status
        end

        context 'exit status is non-zero' do
          let(:exit_status) { rand(99) + 1 }

          specify do
            expect { fixture.vendor }.to raise_error
          end
        end

        context 'exit status 0' do
          let(:exit_status) { 0 }

          specify do
            expect { fixture.vendor }.not_to raise_error
          end
        end
      end
    end
  end
end