require 'spec_helper'

module Machete
  module CF
    describe AppFile do
      let(:app) { double(:app, name: 'app_name') }
      subject(:app_file) { AppFile.new(app) }

      describe '#has_file?' do
        before do
          allow(SystemHelper).
            to receive(:run_cmd).
                with('cf files app_name filename')
        end

        specify do
          expect(app_file.has_file?('filename')).to be_truthy
        end
      end
    end
  end
end