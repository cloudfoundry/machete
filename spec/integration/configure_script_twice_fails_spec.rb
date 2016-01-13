require 'spec_helper'

describe 'scripts/configure_deployment' do
  context 'when some subcommand fails' do
    subject { `yes | ./scripts/configure_deployment 2>&1` }

    before do
      unless ENV['VAGRANT_CWD']
        puts <<VAGRANT_CWD_WARNING

=========================================================
ERROR: Your deployment is not properly configured.
Please make sure VAGRANT_CWD is set before running specs:
export VAGRANT_CWD=path/to/bosh-lite
=========================================================
VAGRANT_CWD_WARNING
        exit 1
      end
      # Ensure ./scripts/configure_deployment has ran at least once
      subject
    end

    it "should completely fail" do
      subject
      repeat_run_result = $?.exitstatus
      expect(repeat_run_result).to eq 1
    end
  end
end
