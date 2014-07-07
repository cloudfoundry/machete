require 'spec_helper'

module Machete
  describe App do
    let(:host) { double(:host) }
    let(:options) { Hash.new }
    let(:database_url_builder) { double(:database_url_builder) }
    let(:database_url) { double(:database_url) }

    subject(:app) { App.new('path/to/example_app', host, options) }

    before do
      allow(DatabaseUrlBuilder).
        to receive(:new).
             with(no_args).
             and_return(database_url_builder)
    end

    describe '#name' do
      specify do
        expect(app.name).to eql 'example_app'
      end
    end

    describe '#env' do
      context 'with_pg: true' do
        context 'default database name' do
          let(:options) do
            {
              with_pg: true
            }
          end

          before do
            allow(database_url_builder).
              to receive(:execute).
                  with(database_name: nil).
                   and_return(database_url)
          end

          specify do
            expect(app.env['DATABASE_URL']).
              to eql database_url
          end
        end

        context 'specified database name' do
          let(:options) do
            {
              with_pg: true,
              database_name: 'my_database'
            }
          end

          before do
            allow(database_url_builder).
              to receive(:execute).
                   with(database_name: 'my_database').
                   and_return(database_url)
          end

          specify do
            expect(app.env['DATABASE_URL']).
              to eql database_url
          end
        end
      end
    end

    describe '#environment_variables?' do
      context 'has no environment variables' do
        let(:options) { Hash.new }

        specify do
          expect(app.environment_variables?).to be false
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
          expect(app.environment_variables?).to be true
        end
      end

      context 'with_pg: true' do
        let(:options) do
          {
            with_pg: true
          }
        end

        before do
          allow(database_url_builder).
            to receive(:execute).
                 with(database_name: nil).
                 and_return(database_url)
        end

        specify do
          expect(app.environment_variables?).to be true
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
