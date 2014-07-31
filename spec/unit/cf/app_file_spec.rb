require 'spec_helper'

module Machete
  module CF
    describe AppFile do
      let(:app) { double(:app, name: 'app_name') }

      subject(:app_file) { AppFile.new(app) }

      before do
        allow(SystemHelper).
          to receive(:run_cmd).
          with('cf files app_name filename')
      end

      describe '#has_file?' do
        context 'file exists on cf' do
          before do
            # stub $? and return 0
            `(exit 0)`
          end

          specify do
            expect(app_file.has_file?('filename')).to be_truthy
          end
        end

        context 'file does not exist on cf' do
          before do
            # stub $? and return non-zero
            `(exit 1)`
          end

          specify do
            expect(app_file.has_file?('filename')).to be_falsy
          end

        end
      end
    end
  end
end
