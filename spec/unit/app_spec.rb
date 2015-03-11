require 'spec_helper'

module Machete
  describe App do
    let(:host) { double(:host) }
    let(:options) { Hash.new }

    let(:app) { App.new('path/to/example_app', host, options) }

    describe '#name' do
      specify do
        expect(app.name).to eql 'example_app'
      end
    end

    describe '#needs_setup?' do
      context 'has no environment variables' do
        let(:options) { Hash.new }

        specify do
          expect(app.needs_setup?).to be false
        end
      end

      context 'has environment variables' do
        let(:options) do
          {
            env: {
              MY_ENV_VAR: 'my_env_val'
            }
          }
        end

        specify do
          expect(app.needs_setup?).to be true
        end
      end

      context 'with_pg: true' do
        let(:options) do
          {
            with_pg: true
          }
        end

        specify do
          expect(app.needs_setup?).to be true
        end
      end
    end

    describe '#src_directory' do
      specify do
        expect(app.src_directory).to eql 'cf_spec/fixtures/path/to/example_app'
      end
    end

    describe '#stack' do
      let(:app) { App.new('path/to/example_app', host, options) }
      context 'when CF_STACK is lucid64' do
        specify do
          allow(ENV).to receive(:[]).with('CF_STACK').and_return('lucid64')
          expect(app.stack).to eql 'lucid64'
        end
      end

      context 'when CF_STACK is cflinuxfs2' do
        specify do
          allow(ENV).to receive(:[]).with('CF_STACK').and_return('cflinuxfs2')
          expect(app.stack).to eql 'cflinuxfs2'
        end
      end
    end
  end
end
