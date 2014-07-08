require 'spec_helper'

module Machete
  describe App do
    let(:host) { double(:host) }
    let(:options) { Hash.new }

    subject(:app) { App.new('path/to/example_app', host, options) }

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
  end
end
