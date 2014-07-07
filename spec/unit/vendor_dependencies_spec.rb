require 'spec_helper'

module Machete
  describe VendorDependencies do
    let(:app) { double(:app, src_directory: src_directory) }
    let(:src_directory) { '/path/to/src' }

    subject(:vendor_dependencies) { VendorDependencies.new }

    before do
      allow(File).
        to receive(:exist?).
             with('package.sh').
             and_return(package_script_exists)

      allow(Dir).
        to receive(:chdir).
             with(src_directory).
             and_yield
    end

    context 'there is no package script' do
      let(:package_script_exists) { false }

      specify do
        expect(SystemHelper).not_to receive(:run_cmd)

        vendor_dependencies.execute(app)

        expect(Dir).
          to have_received(:chdir)
      end
    end

    context 'there is a package script' do
      let(:package_script_exists) { true }

      before do
        allow(Machete.logger).
          to receive(:action).
               with('Vendoring dependencies before push')

        allow(Bundler).
          to receive(:with_clean_env).
               and_yield

        allow(SystemHelper).
          to receive(:run_cmd).
               with('./package.sh')

        allow(SystemHelper).
          to receive(:exit_status).
               and_return exit_status
      end

      context 'zero exit status' do
        let(:exit_status) { 0 }

        specify do
          expect {
            vendor_dependencies.execute(app)
          }.not_to raise_error

          expect(Machete.logger).
            to have_received(:action)

          expect(Bundler).
            to have_received(:with_clean_env)

          expect(SystemHelper).
            to have_received(:run_cmd)

          expect(Dir).
            to have_received(:chdir)
        end
      end

      context 'non-zero exit status' do
        let(:exit_status) { -1 }

        specify do
          expect {
            vendor_dependencies.execute(app)
          }.to raise_error

          expect(Machete.logger).
            to have_received(:action)

          expect(Bundler).
            to have_received(:with_clean_env)

          expect(SystemHelper).
            to have_received(:run_cmd)

          expect(Dir).
            to have_received(:chdir)
        end
      end
    end
  end
end