# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SquareLite::Create::Catalog do
  let(:client) { build_generic_client }
  let(:existing_ids) { {} }
  let(:creator) { described_class.new(client, existing_ids) }

  def expect_client_req_params(objects: {}, json: { errors: [] })
    url      = 'v2/catalog/batch-upsert'
    req_mock = double('Typheous::Request', options: {}, run: double('resonse', body: json.to_json))

    expect(client).to receive(:request)
      .with(:post, url, paginate: false, params: hash_including(batches: [{ objects: objects }]))
      .and_return(req_mock)
  end

  let(:json) { { errors: [] } }

  describe '#commit!' do
    subject(:commit) do
      creator.commit!(&block)
      category_attrs
    end

    context 'given a block' do
      let(:category_attrs) { { name: 'category1' } }
      let(:block)          { proc { |c| c.category(category_attrs) } }

      let(:req_params) { [hash_including(category_data: { name: 'category1' }, type: :CATEGORY)] }

      before { expect_client_req_params(objects: req_params, json: json) }

      describe 'yields idempotency key' do
        it 'generates an idempotency key' do
          creator.commit! do |c, k|
            expect(k).to match(/[\-a-z0-9]+/)
            c.category(category_attrs)
          end
        end

        it 'yields idempotency key' do
          creator.commit!(key: 'fake-key') do |c, k|
            expect(k).to eq('fake-key')
            c.category(category_attrs)
          end
        end
      end

      context 'creates category' do
        it { is_expected.to include(id: be_a(String).and(start_with('#'))) }

        context 'with specified #new_id' do
          before { category_attrs.merge!(id: '#new_id') }

          it { is_expected.to include(id: '#new_id') }
        end
      end

      context 'raises SquareConnect errors' do
        let(:req_params) { [hash_including(category_data: { name: 'category1' }, type: :CATEGORY)] }
        let(:json) { { errors: ['FakeError'] } }

        it { is_expected_to_raise(SquareLite::ConnectAPIError) }
      end

      context 'creates categories' do
        let(:block) do
          proc do |c|
            c.categories({ name: 'category1', type: :CATEGORY }, { name: 'category2', type: :CATEGORY })
          end
        end

        let(:req_params) do
          [
            hash_including(category_data: { name: 'category1' }, type: :CATEGORY),
            hash_including(category_data: { name: 'category2' }, type: :CATEGORY),
          ]
        end
      end

      context 'creates category from prior to block' do
        before { creator.category(name: 'category0', type: :CATEGORY) }

        let(:req_params) do
          [
            hash_including(category_data: { name: 'category0' }, type: :CATEGORY),
            hash_including(category_data: { name: 'category1' }, type: :CATEGORY),
          ]
        end

        it { is_expected.to include(:id) }
      end

      context 'with existing ids' do
        let(:existing_ids) { { id1: 0, id2: 0, id3: 0 } }

        let(:category_attrs) { { name: 'category1', id: :id1, version: 0 } }
        let(:req_params)     { [{ category_data: { name: 'category1' }, type: :CATEGORY, version: 0, id: :id1 }] }

        it { is_expected.to include(id: :id1) }
      end

      context 'with manual new id' do
        let(:req_params) { [{ id: '#new_id', category_data: { name: 'category1' }, type: :CATEGORY }] }

        before { category_attrs[:id] = '#new_id' }

        it { is_expected.to include(id: '#new_id') }
      end
    end
  end

  describe 'dyanmic methods' do
    let(:category1) { { name: 'category1' } }
    let(:category2) { { name: 'category2' } }

    let(:req_params) do
      [
        hash_including(category_data: hash_including(name: 'category1')),
        hash_including(category_data: hash_including(name: 'category2')),
      ]
    end

    context 'commitable' do
      after { creator.category!(category1) }

      let(:req_params) { [hash_including(category_data: hash_including(name: 'category1'))] }

      it { expect_client_req_params(objects: req_params) }
    end

    context 'bulkable' do
      after { creator.categories(category1, category2); creator.commit! }

      it { expect_client_req_params(objects: req_params) }
    end

    context 'bulk commit' do
      after { creator.categories!(category1, category2) }

      it { expect_client_req_params(objects: req_params) }
    end
  end

  describe '#clear!' do
    it 'has no side effects on blank client' do
      expect(creator.hash).to eq(creator.clear!.hash)
    end

    context 'after creating an item' do
      it 'keeps id cache'
      it 'can save new item'
    end
  end

  describe 'catalog resources' do
    subject do
      expect { creator.send(resource, attrs) }.to(change { attrs.hash })
      expect { creator.commit! }.to_not(change { attrs.hash })
      attrs
    end

    let(:attrs)   { { name: "test-#{resource}" } }
    let(:json)    { { errors: [] } }
    let(:creates) { true }

    before { expect_client_req_params(objects: req_params, json: json) if creates }

    describe '#tax' do
      let(:resource)   { :tax }
      let(:req_params) { [hash_including(tax_data: { name: 'test-tax' }, type: :TAX)] }

      it { is_expected.to include(id: String) }
      it { is_expected.to_not include(:tax_data) }
    end

    describe '#item' do
      let(:resource)   { :item }
      let(:req_params) { [hash_including(type: :ITEM, item_data: { name: 'test-item' })] }

      it { is_expected.to include(id: String) }

      context 'with nested variation' do
        let(:variation_attrs) { [{ name: 'test-nested-variation' }] }

        let(:req_params) do
          [hash_including(type: :ITEM, item_data: { name: 'test-item', variations: variation })]
        end

        let(:variation) do
          [hash_including(type: :ITEM_VARIATION, item_variation_data: hash_including(name: 'test-nested-variation'))]
        end

        before { attrs.merge!(variations: variation_attrs) }

        it { is_expected.to include(id: String) }
        it { is_expected.to include(variations: [hash_excluding(:item_variation_data)]) }
        it { is_expected.to include(id: attrs[:variations].first[:item_id]) }

        context 'new variation on existing item' do
          let(:existing_ids) { { 'item1' => 12, 'wrong-id' => 0 } }

          before { attrs.merge!(id: 'item1', version: existing_ids['item1']) }

          it { is_expected.to include(variations: [hash_including(item_id: 'item1')]) }

          context 'with mismatched item_id' do
            let(:creates) { false }
            let(:variation_attrs) { [{ name: 'test-nested-variation', item_id: 'wrong-id' }] }

            it { is_expected_to_raise(SquareLite::VariationMismatchedItemIdError) }
          end
        end
      end

      context 'product_type' do
        let(:creates) { false }

        before { attrs[:product_type] = '...' }
        before { expect(creator).to_not receive(:commit!) }

        it { is_expected_to_raise(SquareLite::UpdatingReadOnlyError) }
      end
    end

    describe '#variation' do
      let(:resource) { :variation }
      let(:existing_ids) { { 'fake-item-id' => 1234 } }
      let(:req_params) { [hash_including(item_variation_data: { name: 'test-variation', item_id: 'fake-item-id' }, type: :ITEM_VARIATION)] }

      before { attrs.merge!(item_id: 'fake-item-id') }

      it { is_expected.to include(id: String) }
      it { is_expected.to_not include(:item_variation_data) }
    end
  end
end
