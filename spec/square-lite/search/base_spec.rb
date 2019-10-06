# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SquareLite::Search::Common do
  let(:thing_class) { Class.new(SquareLite::Search::Base) }
  let(:thing)       { thing_class.new(client, params) }
  let(:client)      { nil }
  let(:params)      { {} }

  describe '#params' do
    subject { thing.params }

    context 'no expected_params, no rename_params' do
      it { is_expected.to eq({}) }

      context 'constructed with params' do
        let(:params) { { k1: 1, k2: 2 } }

        it { is_expected.to eq({}) }
      end
    end

    context 'with expected_params' do
      before do
        thing_class.instance_eval do
          expected_params << :key1
        end
      end

      it { is_expected.to eq({}) }

      context 'constructed with params' do
        let(:params) { { key1: 1, key2: 2 } }

        it { is_expected.to eq(key1: 1) }
      end
    end

    context 'with rename_params' do
      before do
        thing_class.instance_eval do
          rename_param(key1: :key2)
        end
      end

      it { is_expected.to eq({}) }

      context 'constructed with params' do
        let(:params) { { key1: 2 } }

        it { is_expected.to eq(key2: 2) }
      end

      context 'and expected_params' do
        before do
          thing_class.instance_eval do
            expected_params << :key3
          end
        end

        let(:params) { { key1: 2, key3: 3, key4: 4 } }

        it { is_expected.to eq(key2: 2, key3: 3) }
      end
    end
  end
end
