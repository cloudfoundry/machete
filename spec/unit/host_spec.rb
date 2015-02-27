require 'spec_helper'

describe Machete::Host do
  describe 'Creating the correct host for the environment' do
    context 'VAGRANT_CWD is set' do

      before do
        allow(ENV).to receive(:[]).with('VAGRANT_CWD').and_return('/tmp')
      end

      specify 'it uses the Vagrant host' do
        expect(Machete::Host.create).to be_instance_of(Machete::Host::Vagrant)
      end
    end

    context 'VAGRANT_CWD is not set' do
      specify 'it uses the Aws host' do
        expect(Machete::Host.create).to be_instance_of(Machete::Host::Aws)
      end
    end
  end
end
