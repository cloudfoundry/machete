require 'spec_helper'

module Machete
  describe Host::Aws do

    subject(:host) { Host::Aws.new }

    describe '#create_log_manager' do
      let(:log_manager) { double(:log_manager) }

      before do
        allow(Host::Aws::Log).to receive(:new).
                                       with(host).
                                       and_return(log_manager)
      end

      specify do
        expect(host.create_log_manager).to eql(log_manager)
      end
    end

    describe '#run' do
      context 'interfaces with an interactive BOSH SSH' do
        let(:stdin) { double(:stdin) }
        let(:stdout) { double(:stdout) }

        before do
          pid = 1234
          allow(Bundler).to receive(:with_clean_env).and_yield
          allow(ENV).to receive(:[])
                          .with('BOSH_TARGET')
                          .and_return('microbosh.my.host')
          allow(PTY).to receive(:spawn).and_yield(stdout, stdin, pid)
          allow(stdin).to receive(:write)
          allow(Machete::SystemHelper).to receive(:run_cmd)
          allow(stdout).to receive(:read).and_return(':~$ ', "---COMMAND START---\r\n---COMMAND STOP---\r\n", nil)
        end

        it 'connects remotely to BOSH with a PTY' do
          expect(PTY).to receive(:spawn)
                          .with("bosh ssh runner_z1 --gateway_user vcap --gateway_host microbosh.my.host --default_password p")
          host.run("echo 'hello there'", :runner_z1)
        end

        it 'sends the command when prompt is ready' do
          expect(stdin).to receive(:write).with("echo '---COMMAND START---'; echo 'hello there'; echo '---COMMAND STOP---'\n")
          expect(stdout).to receive(:read).and_return(':~$ ', "---COMMAND START---\r\n---COMMAND STOP---\r\n", nil)
          host.run("echo 'hello there'", :runner_z1)
        end

        it 'filters out the output between the fenceposts' do
          allow(stdin).to receive(:write)
          allow(stdout).to receive(:read).with(1).and_return(':~$ ', <<-OUTPUT, nil)
This is bosh output
More Bosh output
echo ---COMMAND START---; echo blah; echo ---COMMAND STOP---
---COMMAND START---
hello there
---COMMAND STOP---
Last Bosh output
          OUTPUT
          expect(host.run("echo 'hello there'", :runner_z1)).to eql("hello there\n")
        end

        it 'handles an array of commands' do
          expect(stdin).to receive(:write).with("echo '---COMMAND START---'; echo 'hello'; echo 'there'; echo '---COMMAND STOP---'\n")
          host.run(["echo 'hello'", "echo 'there'"], :runner_z1)
        end

        it 'accepts an SSH prompt to allow RSA key access' do
          expect(stdout).to receive(:read).and_return('connecting (yes/no)? ', ':~$ ', "---COMMAND START---\r\n---COMMAND STOP---\r\n", nil)
          expect(stdin).to receive(:write).with("yes\n")
          expect(stdin).to receive(:write).with("echo '---COMMAND START---'; echo 'hello there'; echo '---COMMAND STOP---'\n")
          host.run("echo 'hello there'", :runner_z1)
        end

        it 'runs commands on different vms' do
          expect(PTY).to receive(:spawn)
                          .with("bosh ssh postgres_z1 --gateway_user vcap --gateway_host microbosh.my.host --default_password p")
          host.run("echo 'hello there'", :postgres_z1)
        end

        it 'previous BOSH SSH sessions logged in known hosts' do
          expect(Machete::SystemHelper).to receive(:run_cmd)
            .with("fgrep [localhost] ~/.ssh/known_hosts | cut -d ' ' -f1  | xargs -n1 ssh-keygen -R 2>&1")
          host.run("echo 'hello there'", :postgres_z1)
        end
      end

      context "without a BOSH_TARGET" do
        before do
          allow(ENV).
            to receive(:[]).
                 with('BOSH_TARGET').
                 and_return(nil)
        end

        specify do
          expect{ host.run("echo 'hello there'", :vm_name) }.to raise_error("BOSH_TARGET must be set")
        end
      end
    end
  end
end
