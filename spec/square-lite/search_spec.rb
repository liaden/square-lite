# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SquareLite::Search do
  let(:search_client) { SquareLite::Search.new(build_generic_client) }

  describe '#for' do
    subject(:resource_search) { search_client.for(*things) }
    context 'no arguments' do
      let(:things) { [] }

      it { is_expected.to be_a(SquareLite::Search) }
    end

    context 'catalog' do
      let(:things) { [:catalog] }

      it { is_expected.to be_a(SquareLite::Search::Catalog) }
    end

    context 'item' do
      let(:things) { [:item] }

      it { is_expected.to be_a(SquareLite::Search::Catalog) }
    end

    context 'item and item_variant' do
      let(:things) { [:item, :item_variation] }

      it { is_expected.to be_a(SquareLite::Search::Catalog) }
    end

    context 'unknown' do
      it 'is expected to raise error' do
        expect {
          search_client.for('not_a_real_thing42')
        }.to raise_error(SquareLite::UnknownForTypeError)
      end
    end
  end
end
