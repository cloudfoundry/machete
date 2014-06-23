require './spec/spec_helper'
require 'machete'

describe Machete::Fixture do
  subject(:fixture) { Machete::Fixture.new('path/to/kyle_has_an_awesome_app') }

  describe 'SystemHelper' do
    specify do
      expect(Machete::Fixture.method_defined?(:run_cmd)).to be_truthy
    end
  end

  describe '#directory' do
    specify do
      expect(fixture.directory).to eql 'cf_spec/fixtures/path/to/kyle_has_an_awesome_app'
    end
  end

  describe '#vendor' do
    before do
      allow(Machete.logger).to receive(:action)
      allow(Bundler).to receive(:with_clean_env).and_yield
      allow(fixture).to receive(:run_cmd)
    end

    context 'when there is no script' do
      before do
        allow(File).to receive(:exists?).with('package.sh').and_return(false)
        fixture.vendor
      end

      specify do
        expect(Machete.logger).not_to have_received(:action).with('Vendoring dependencies before push')
      end

      specify do
        expect(fixture).not_to have_received(:run_cmd).with('./package.sh')
      end

      specify do
        expect(fixture).not_to have_received(:run_cmd)
      end
    end

    context 'when there is a script' do
      before do
        allow(File).to receive(:exists?).with('package.sh').and_return(true)
        fixture.vendor
      end

      specify do
        expect(Machete.logger).to have_received(:action).with('Vendoring dependencies before push')
      end

      specify do
        expect(Bundler).to have_received(:with_clean_env)
      end

      specify do
        expect(fixture).to have_received(:run_cmd).with('./package.sh')
      end
    end

  end
end

