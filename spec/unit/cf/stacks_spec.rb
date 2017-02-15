# encoding: utf-8
require 'spec_helper'

module Machete
  module CF
    describe Stacks do
      let(:stacks_json) { double(:stacks_json) }

      subject(:stacks_command) { Stacks.new() }

      before do
        allow(SystemHelper)
          .to receive(:run_cmd)
          .with("cf curl /v2/stacks")
          .and_return(stacks_json)

        allow(JSON)
          .to receive(:parse)
          .with(stacks_json)
          .and_return(cf_response)
      end

      context 'no stacks' do
        let(:cf_response) do
          {
            'resources' => []
          }
        end
        specify do
          stacks = stacks_command.execute
          expect(stacks.size).to eql 0
        end
      end

      context 'less than one page of stacks' do
        let(:cf_response) do
          {
            'resources' => [
              { "entity" => {
                  "name" => "cflinuxfs2" }},
              { "entity" => {
                  "name" => "windows2012r2" }}
            ]
          }
        end
        specify do
          stacks = stacks_command.execute
          expect(stacks).to eql %w(cflinuxfs2 windows2012r2)
        end
      end
    end
  end
end
