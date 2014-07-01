require 'spec_helper'

module Machete
  describe SystemHelper do
    describe 'run_cmd' do
      before  { allow(Machete).to receive(:logger).and_return(double.as_null_object) }

      describe 'returned output' do
        subject { SystemHelper.run_cmd('echo hello') }

        it { should eql "hello\n" }
      end

      describe 'exit status' do
        subject { SystemHelper }

        specify do
          subject.run_cmd('exit 1')
          expect(subject.exit_status).to eql 1

          subject.run_cmd('exit 0')
          expect(subject.exit_status).to eql 0
        end
      end

      context 'running silently' do

        subject { Machete.logger }

        before { SystemHelper.run_cmd('echo hello', true) }

        it { should_not have_received("info") }

      end

      context 'with logging' do

        subject { Machete.logger }

        before { SystemHelper.run_cmd('echo hello') }

        it { should have_received('info').with("$ echo hello") }

        it { should have_received('info').with("hello\n") }

      end
    end
  end
end