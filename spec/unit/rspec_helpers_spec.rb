# encoding: utf-8
require 'spec_helper'

module Machete
  describe RSpecHelpers do
    describe '#skip_if_cf_api_below' do
      let(:version)               { '2.57.0' }
      let(:reason)                { 'skip reason here' }
      let(:actual_cf_api_version) { nil }
      let(:cf_api_output)         { "API endpoint: https://api.local.pcfdev.io (API version: #{actual_cf_api_version})" }

      before do
        allow_any_instance_of(Machete::CF::API).to receive(:execute).and_return(cf_api_output)
      end

      subject { described_class.skip_if_cf_api_below(version: version, reason: reason) }

      context 'version is not supplied' do
        let(:version) { nil }

        it 'raises an exception and demands a version' do
          expect { subject }.to raise_error(ArgumentError, 'you must supply a version')
        end
      end

      context 'reason is not supplied' do
        let(:reason) { nil }

        it 'raises an exception and demands a reason' do
          expect { subject }.to raise_error(ArgumentError, 'you must supply a reason')
        end
      end

      context 'cf api version is greater than minimum version' do
        let(:actual_cf_api_version) { '2.99.9' }

        it 'does not skip' do
          expect_any_instance_of(described_class).to_not receive(:skip)
          subject
        end
      end

      context 'cf api version is lower than minimum version' do
        let(:actual_cf_api_version) { '1.99.9' }

        it 'does skip' do
          expect_any_instance_of(described_class).to receive(:skip).with('skip reason here')
          subject
        end
      end
    end

    describe '#skip_if_proprietary_dependencies_are_not_available' do
      subject { described_class.skip_if_proprietary_dependencies_are_not_available }

      describe 'Oracle Instant Client Lite and OCI SDK' do
        context 'downloaded dependencies are available' do
          before do
            allow(File).to receive(:exist?).and_return(true)
          end

          it 'checks the file system for the files' do
            expect(File).to receive(:exist?).with('/oracle/libclntsh.so').and_return(true)
            expect(File).to receive(:exist?).with('/oracle/libclntsh.so.12.1').and_return(true)
            expect(File).to receive(:exist?).with('/oracle/libipc1.so').and_return(true)
            expect(File).to receive(:exist?).with('/oracle/libmql1.so').and_return(true)
            expect(File).to receive(:exist?).with('/oracle/libnnz12.so').and_return(true)
            expect(File).to receive(:exist?).with('/oracle/libociicus.so').and_return(true)
            expect(File).to receive(:exist?).with('/oracle/libons.so').and_return(true)

            subject
          end

          it 'does not skip a test' do
            expect_any_instance_of(described_class).to_not receive(:skip)

            subject
          end
        end

        context 'the dependencies are missing' do
          before do
            allow(File).to receive(:exist?).and_return(false)
          end

          it 'skips a test' do
            expect_any_instance_of(described_class).to receive(:skip)

            subject
          end
        end
      end
    end
  end
end
