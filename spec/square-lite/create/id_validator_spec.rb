# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SquareLite::Create::IdValidator do
  let(:existing_ids) { Set.new }
  let(:data) { [hash1, hash2, hash3].compact }

  let(:hash1) { { id: '#hash1_id' } }
  let(:hash2) { nil }
  let(:hash3) { nil }

  let(:existing_deep_hash) do
    {
      id:         'item_id',
      name:       'item_name',
      variations: [{
        id:                  'variation_id',
        item_variation_data: {
          item_id: 'item_id',
          name:    'variation_name',
        },
      }],
    }
  end

  subject(:run_validation) { described_class.new(existing_ids).validate!(*data) }

  describe '#validate' do
    context 'empty hash' do
      let(:data) { {} }

      it { is_expected.to be true }
    end

    context 'empty array' do
      let(:data) { [] }

      it { is_expected.to be true }
    end

    context 'bad data' do
      let(:data) { 0 }

      it { is_expected_to_raise(SquareLite::UnknownTypeGivenError) }
    end

    context 'missing new id' do
      let(:hash1) { { id: '#missing_id' } }

      it { is_expected.to be true }
    end

    # new variations should end up being listed multiple times
    # so maybe this isn't really an error condition to prevent?
    context 'duplicate new id' do
      let(:hash2) { hash1 }

      it { is_expected_to_raise(SquareLite::DuplicateIdError) }
    end

    context 'tax_ids' do
      let(:hash1) { { id: '#item_id', tax_ids: ['#taxid'] } }

      it { is_expected.to be true }
    end

    describe 'id key' do
      [:id, :ID, 'id', 'ID'].each do |id_key|
        context "= #{id_key}" do
          let(:hash1) { { id_key => '#newid' } }

          it { is_expected.to be true }
        end
      end
    end

    context 'association' do
      let(:hash1) { { id: '#tax_id' } }
      let(:hash2) { { id: '#associated_to_tax', tax_ids: ['#tax_id'] } }

      it { is_expected.to be true }
    end

    context 'deeply nested' do
      let(:hash1) do
        {
          id: '#item_id',
          name: 'item_name',
          variations: [{
            id: '#variation_id',
            item_variation_data: {
              item_id: '#item_id',
              name: 'variation_name'
            }
          }]
        }
      end

      it { is_expected.to be true }
    end

    # context 'update missing'
    # context 'associate item with missing'
    # context 'duplicate new items'

    context 'existing ids' do
      let(:existing_ids) { Set.new(['existing1', 'existing2']) }

      describe 'id key' do
        [:id, :ID, 'id', 'ID'].each do |id_key|
          context "= #{id_key}" do
            let(:hash1) { { id_key => 'existing1' } }

            it { is_expected.to be true }
          end
        end
      end

      # TODO; testing to make this more precise
      context 'update duplication' do
      end

      context 'update existing: deeply nested' do
        let(:existing_ids) { Set.new(['item_id', 'variation_id']) }

        let(:hash1) do
          {
            id: 'item_id',
            name: 'item_name',
            variations: [{
              id: 'variation_id',
              item_variation_data: {
                item_id: 'item_id',
                name: 'variation_name'
              }
            }]
          }
        end

        it { is_expected.to be true }
      end

      context 'associate item with existing'
      context 'create new but already existing'
    end
  end
end
