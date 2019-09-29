# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SquareLite::Search::Orders do
  let(:search) { build_search(:orders) }

  describe 'validating' do
    describe 'two date_time_filters' do
      it 'raises SquareLite::MismatchedParams' do
        search.created(on: DateTime.now)
        expect { search.updated(on: DateTime.now) }.to raise_error(SquareLite::MismatchedParams)
      end
    end
  end

  describe '#initialize' do
    subject(:search) { described_class.new(nil, at).params }

    describe 'at:' do
      let(:at) { { at: nil } }

      it { is_expected.to eq({}) }

      context '1 location' do
        let(:at) { { at: 'loc1' } }

        it { is_expected.to include(location_ids: ['loc1']) }
      end

      context '1 location (array)' do
        let(:at) { { at: ['loc1'] } }

        it { is_expected.to include(location_ids: ['loc1']) }
      end

      context '11 locations' do
        let(:at) { { at: ['loc1'] * 11 } }

        it { expect { search }.to raise_error(SquareLite::TooManyError) }
      end
    end
  end

  describe '#where' do
    let(:where) { search.where(:open, from: ['a', 'b'], customers: 'c1', created: { on: DateTime.now }) }
    let(:params) { where.params[:query][:filter] }

    it { expect(params.dig(:state_filter, :states)).to eq([:open]) }
    it { expect(params.dig(:source_filter, :source_names)).to eq(['a', 'b']) }
    it { expect(params.dig(:customer_filter, :customer_ids)).to eq(['c1']) }
    it { expect(params.dig(:date_time_filter, :created_at)).to include(:start_at, :end_at) }
  end

  describe 'params' do
    subject { search.params }

    describe '#id!' do
    end

    describe '#ids!' do
    end

    describe '#fullfilment' do
      subject { search.fulfillment(data).params[:query][:filter][:fulfillment_filter] }

      let(:data) { { types: :PICKUP, states: :COMPLETED } }

      it { is_expected.to eq(fulfillment_types: [:PICKUP], fulfillment_states: [:COMPLETED]) }

      context 'handles lowercase values' do
        before { data.transform_values!(&:downcase) }

        it { is_expected.to eq(fulfillment_types: [:PICKUP], fulfillment_states: [:COMPLETED]) }
      end

      context 'handles string values' do
        before { data.transform_values!(&:to_s) }

        it { is_expected.to eq(fulfillment_types: ['PICKUP'], fulfillment_states: ['COMPLETED']) }
      end

      context 'multipe states' do
        before do
          data[:states] = %i[COMPLETED PREPARED]
          data.delete(:types)
        end

        it { is_expected.to eq(fulfillment_types: %i[PICKUP SHIPMENT], fulfillment_states: %i[COMPLETED PREPARED]) }
      end
    end

    %i[closed created updated].each do |time_filter|
      describe "##{time_filter}" do
        subject(:applied) { search.send(time_filter, **data).params[:query][:filter][:date_time_filter] }

        let(:now)   { DateTime.now }
        let(:range) { (now - 1)..now }
        let(:name)  { "#{time_filter}_at".to_sym }

        describe 'on' do
          let(:data) { { on: Date.new(2017, 1, 14) } }

          it { is_expected.to eq(name => { start_at: Date.new(2017, 1, 14), end_at: Date.new(2017, 1, 15) }) }
        end

        describe 'until' do
          let(:data) { { until: now } }

          it { is_expected.to include(name => include(end_at: now)) }
        end

        describe 'since' do
          let(:data) { { since: Date.new(2013, 1, 18) } }

          it { is_expected.to include(name => include(start_at: data[:since])) }

          context 'and during' do
            before { data[:during] = range }

            it { expect { applied }.to raise_error(SquareLite::TimeRangeError) }
          end
        end

        describe 'since and until' do
          let(:data) { { since: Date.new(2013, 1, 18), until: now } }

          it { is_expected.to include(name => include(start_at: data[:since], end_at: now)) }

          context 'and on' do
            before { data[:on] = now }

            it { expect { applied }.to raise_error(SquareLite::TimeRangeError) }
          end

          context 'since > until' do
            before { data[:since] = data[:until] + 1 }

            it { expect { applied }.to raise_error(SquareLite::EmptyRangeError) }
          end
        end

        describe 'during' do
          let(:data) { { during: range } }

          it { is_expected.to include(name => include(start_at: range.first, end_at: range.last)) }

          context 'empty range' do
            let(:range) { (now + 1)..now }

            it { expect { applied }.to raise_error(SquareLite::EmptyRangeError) }
          end
        end
      end
    end
  end
end
