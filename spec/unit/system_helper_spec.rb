require 'spec_helper'

module Machete
  describe SystemHelper do
    describe 'run_cmd' do
      before  { allow(Machete).to receive(:logger).and_return(double.as_null_object) }

      context 'returned output' do

        subject { SystemHelper.run_cmd('echo hello') }

        it { should eql "hello\n" }

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