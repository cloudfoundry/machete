# encoding: utf-8
require 'spec_helper'
require 'machete/matchers'

module Machete
  describe '#have_header' do
    let(:browser) { double(:browser, headers: { 'x-included' => ['something', 'another thing'] }) }

    context 'when the response header does include the matched text' do
      it 'passes' do
        expect(browser).to have_header('X-Included')
        expect(browser).to have_header('something')
        expect(browser).to have_header('another thing')
      end
    end

    context 'when the response header does not include the matching text' do
      it 'fails' do
        expect(browser).not_to have_header('X-Not-Included')
      end
    end
  end
end
