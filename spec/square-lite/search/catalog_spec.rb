# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SquareLite::Search::Catalog do
  let(:search_types) { ['item'] }
  let(:search)  { build_search(:catalog).for(*search_types) }
  let(:neg_inf) { Float::INFINITY * -1 }
  let(:inf)     { Float::INFINITY }

  describe 'validating' do
    describe 'type' do
      subject { -> { query.validate! } }
      context 'is present' do
        context 'query search' do
          let(:query) { search.for('item').exactly(name: :things_name) }

          it { is_expected.to_not raise_error }
        end

        context 'all' do
          let(:query) { search.for('item_variation').all }

          it { is_expected.to_not raise_error }
        end
      end

      context 'is unspecified' do
        context 'query search' do
          let(:query) { search.for.exactly(name: :things_name) }

          it { is_expected.to_not raise_error }
        end

        context 'all search' do
          let(:query) { search.for.all }

          it { is_expected.to_not raise_error }
        end

        context 'id search' do
          let(:query) { search.for.id('tid') }

          it { is_expected.to_not raise_error }
        end
      end

      context 'unknown type' do
        it 'raises UnknownSearchTypeError' do
          expect { search.for('UNKNOWN_TYPE') }.to raise_error SquareLite::UnknownForTypeError
        end
      end
    end

    describe 'within' do
      subject { -> { search.within(quantity: lower_bound..upper_bound) } }

      context 'empty range' do
        let(:lower_bound) { 2 }
        let(:upper_bound) { 1 }

        it { is_expected.to raise_error(SquareLite::EmptyRangeError) }
      end
    end

    describe 'ordered' do
      subject { -> { search.ordered(ordering) } }

      context 'unknown ordering' do
        let(:ordering) { { name: :random } }

        it { is_expected.to raise_error(SquareLite::UnknownOrderingError) }
      end

      context 'too many attributes' do
        let(:ordering) { { name: :asc, id: :desc } }

        it { is_expected.to raise_error(SquareLite::AmbiguousOrderingError) }
      end

      context 'passing' do
        context 'with just attribute' do
          let(:ordering) { :name }

          it { is_expected.to_not raise_error }
        end

        %i[ASC DESC asc desc].each do |val|
          context "with #{val}" do
            let(:ordering) { { name: val } }

            it { is_expected.to_not raise_error }
          end
        end
      end
    end
  end

  describe 'simple, successful requests' do
    let(:request_params) { nil }

    after  { expect(request).to have_been_made }
    before { expect_req_body(request, request_params) }

    describe '#id!' do
      context 'with a single id' do
        let!(:request) { stub_sq('v2/catalog/object/TEST_ID', :default_resp) }

        it 'makes the request' do
          search.id!('TEST_ID')
        end
      end

      context 'with multiple ids' do
        let!(:request) { stub_sq('v2/catalog/batch-retrieve', :post, :default_resp) }

        let(:request_params) do
          { object_ids: ['TEST_ID_1', 'TEST_ID_2'] }.stringify_keys
        end

        it 'makes the request' do
          search.id!('TEST_ID_1', 'TEST_ID_2')
        end
      end
    end

    describe '#all!' do
      let!(:request) { stub_sq('v2/catalog/list?types=ITEM', :default_resp) }

      it 'makes the request' do
        search.all!
      end
    end

    describe '#exactly' do
      let!(:request) { stub_sq('v2/catalog/search', :post, :default_resp) }

      let(:request_params) do
        {
          object_types: ['ITEM'],
          query:        {
            exact_query: {
              attribute_name:  'name',
              attribute_value: 'things_name',
            },
          },
        }
      end

      it 'makes the request' do
        search.exactly(name: :things_name).fetch!
      end
    end

    describe '#starts_with' do
      stub_search
      let(:request_params) { prefix_query_params }

      it 'makes the request' do
        search.starts_with(name: :e).fetch!
      end
    end

    describe '#with_related' do
      let!(:request) { stub_sq('v2/catalog/object/TEST_ID?include_related_objects=true', :default_resp) }

      it 'makes the request with' do
        search.with_related.id!('TEST_ID')
      end
    end

    describe '#with_deleted' do
      stub_search
      let(:request_params) { prefix_query_params.merge(include_deleted_objects: true) }

      it 'makes the request with' do
        search.with_deleted.starts_with(name: :e).fetch!
      end
    end

    describe '#within' do
      let!(:request) { stub_sq('v2/catalog/search', :post, :default_resp) }
      let(:upper_bound) { 5 }
      let(:lower_bound) { 1 }

      context 'infinite lower bound' do
        let(:request_params) do
          {
            object_types: ['ITEM'],
            query:        {
              sorted_attribute_query: {
                attribute_name:          'quantity',
                initial_attribute_value: upper_bound,
                sort_order:              'DESC',
              },
            },
          }
        end

        it 'makes the request' do
          search.within(quantity: neg_inf..upper_bound).fetch!
        end
      end

      context 'infinite upper bound' do
        let(:request_params) do
          {
            object_types: ['ITEM'],
            query:        {
              sorted_attribute_query: {
                attribute_name:          'quantity',
                initial_attribute_value: lower_bound,
                sort_order:              'ASC',
              },
            },
          }
        end

        it 'makes the request' do
          search.within(quantity: lower_bound..inf).fetch!
        end
      end

      context 'finite bounds' do
        let(:request_params) do
          {
            object_types: ['ITEM'],
            query:        {
              range_query: {
                attribute_name:      'quantity',
                attribute_min_value: lower_bound,
                attribute_max_value: upper_bound,
              },
            },
          }
        end

        it 'makes the request' do
          search.within(quantity: lower_bound..upper_bound).fetch!
        end
      end
    end

    describe '#since' do
      stub_search
      let(:request_params) { prefix_query_params.merge(begin_time: '2019-12-12T00:00:00+00:00') }

      it 'makes the request' do
        search.since(Date.new(2019, 12, 12)).starts_with(name: :e).fetch!
      end
    end

    describe '#limit' do
      stub_search
      let(:request_params) { prefix_query_params.merge(limit: 5) }

      it 'makes the request' do
        search.limit(5).starts_with(name: :e).fetch!
      end
    end

    describe '#ordered' do
      stub_search

      let(:request_params) do
        {
          object_types: ['ITEM'],
          query:        {
            sorted_attribute_query: {
              attribute_name: 'NAME',
              sort_order:     expected_order_value,
            },
          },
        }
      end

      context 'defaults' do
        let(:expected_order_value) { 'DESC' }

        it 'makes the request' do
          search.ordered(:name).fetch!
        end
      end

      context 'with specific order' do
        let(:expected_order_value) { 'ASC' }

        it 'allows specifying order' do
          search.ordered(name: 'asc').fetch!
        end
      end
    end
  end
end
