require 'spec_helper'

describe Machete::Host do
  describe 'Creating the correct host for the environment' do
    before do
      allow(ENV).to receive(:[])
    end

    context 'VAGRANT_CWD is set' do
      specify 'it uses the Vagrant host' do
        expect(ENV).to receive(:[]).with('VAGRANT_CWD').and_return('/tmp')
        expect(Machete::Host.create).to be_instance_of(Machete::Host::Vagrant)
      end
    end

    context 'BOSH TARGET is set' do
      specify 'it uses the Aws host' do
        expect(ENV).to receive(:[]).with('BOSH_TARGET').and_return('/tmp')
        expect(Machete::Host.create).to be_instance_of(Machete::Host::Aws)
      end
    end

    context 'with neither environment variables set' do
      specify 'it uses the unknown host' do
        expect(Machete::Host.create).to be_instance_of(Machete::Host::Unknown)
      end
    end
  end
end
