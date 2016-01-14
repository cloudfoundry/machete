require 'spec_helper'

module Machete
  describe VendorDependencies do
    let(:app) { double(:app, src_directory: src_directory) }
    let(:src_directory) { Dir.mktmpdir }

    subject(:vendor_dependencies) { VendorDependencies.new }

    context 'there is no package script' do
      specify do
        expect(SystemHelper).not_to receive(:run_cmd)

        vendor_dependencies.execute(app)
      end
    end

    context 'there is a package script' do
      before do
        FileUtils.touch(File.join(src_directory, 'package.sh'))
      end

      context 'zero exit status' do
        specify do
          expect(SystemHelper).to receive(:exit_status).and_return(0)
          expect(SystemHelper).to receive(:run_cmd).with('./package.sh')

          expect {
            vendor_dependencies.execute(app)
          }.not_to raise_error
        end
      end

      context 'non-zero exit status' do
        specify do
          expect(SystemHelper).to receive(:exit_status).and_return(-1)
          expect(SystemHelper).to receive(:run_cmd).with('./package.sh')

          expect {
            vendor_dependencies.execute(app)
          }.to raise_error(RuntimeError)
        end
      end
    end
  end
end
