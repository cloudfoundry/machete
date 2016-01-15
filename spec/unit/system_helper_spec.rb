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
          expect { subject.run_cmd('exit 1') }.to raise_error(RuntimeError)
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

      context 'command fails' do
        subject { SystemHelper }
        it 'should raise a RuntimeError' do
          expect { subject.run_cmd('exit 1') }.to raise_error(RuntimeError, "Command 'exit 1' failed.\n\noutput:\n\n")
        end
      end
    end
  end
end
