require 'spec_helper'

describe Machete::SystemHelper do

  let(:system_helper) { Machete::AppController.new('path/app_name') }

  describe 'run_cmd' do

    before  { allow(Machete).to receive(:logger).and_return(double.as_null_object) }

    context 'returned output' do

      subject { system_helper.run_cmd('echo hello') }

      it { should eql "hello\n" }

    end

    context 'running silently' do

      subject { Machete.logger }

      before { system_helper.run_cmd('echo hello', true) }

      it { should_not have_received("info") }

    end

    context 'with logging' do

      subject { Machete.logger }

      before { system_helper.run_cmd('echo hello') }

      it { should have_received('info').with("$ echo hello") }

      it { should have_received('info').with("hello\n") }

    end

  end

end