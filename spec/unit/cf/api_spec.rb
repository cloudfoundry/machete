# encoding: utf-8
require 'spec_helper'

module Machete
  module CF
    describe API do
      let(:cf_api_string) { "example_api_description\n" }
      subject(:api) { API.new }

      before do
        allow(SystemHelper).to receive(:run_cmd).with('cf api').and_return(cf_api_string)
      end

      specify do
        expect(api.execute).to eql 'example_api_description'
      end
    end
  end
end
