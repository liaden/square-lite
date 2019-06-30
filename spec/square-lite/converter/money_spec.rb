# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SquareLite::Converter::Money do
  let(:square_money) { { 'amount' => 1000, 'currency' => 'USD' } }
  let(:money) { Money.new(500, 'USD') }

  let(:square_hash) do
    {
      'price_money'  => square_money.dup,
      'amount_money' => square_money.dup,
    }
  end

  let(:lite_hash) do
    {
      price:  money.dup,
      amount: money.dup,
    }
  end

  describe '.to_square_money' do
    subject { described_class.to_square_money(money) }

    it { is_expected.to eq(amount: 500, currency: 'USD') }
  end

  describe '.from_square_money' do
    subject { described_class.from_square_money(square_money) }

    it { is_expected.to eq(Money.new(1000, 'USD')) }

    context 'with string amount' do
      before { square_money['amount'] = '1000' }
    end
  end

  describe '.money_key' do
    subject { described_class.money_key(attr_name) }

    context 'is already converted' do
      let(:attr_name) { 'price' }

      it { is_expected.to eq('price') }
    end

    context 'converts square connect key to lite key' do
      let(:attr_name) { 'price_money' }

      it { is_expected.to eq('price') }
    end

    context 'it converts a symbol' do
      let(:attr_name) { :discount_money }

      it { is_expected.to eq('discount') }
    end
  end

  describe '.from_square_monies' do
    subject(:converted) { described_class.from_square_monies(square_hash).keys }

    it 'does not mutate' do
      expect { converted }.to_not(change { square_money.hash })
    end

    it { is_expected.to include('price') }
    it { is_expected.to_not include('price_money', :price_money) }

    it { is_expected.to include('amount') }
    it { is_expected.to_not include('amount_money', :amount_money) }

    context 'with symbol keys' do
      before { square_hash.symbolize_keys! }

      it { is_expected.to include('price') }
      it { is_expected.to_not include('price_money', :price_money) }
    end
  end

  describe '.to_square_monies' do
    subject(:converted) { described_class.to_square_monies(lite_hash).keys }

    it 'does not mutate' do
      expect { converted }.to_not(change { lite_hash.hash })
    end

    it { is_expected.to include(:price_money) }
    it { is_expected.to_not include('price', :price) }

    it { is_expected.to include(:amount_money) }
    it { is_expected.to_not include('amount', :amount) }

    context 'with string keys' do
      before { lite_hash.stringify_keys! }

      it { is_expected.to include(:price_money) }
      it { is_expected.to_not include('price', :price) }
    end
  end

  describe '.from_square_monies!' do
    let(:converted) { described_class.from_square_monies(square_hash) }

    it 'mutates argument' do
      expect(square_hash).to include('price_money')
      expect(converted.object_id).to_not eq square_hash.object_id
      expect(converted.keys).to include('price')
      expect(converted.keys).to_not include('price_money')
    end
  end

  describe '.to_square_monies!' do
    let(:converted) { described_class.to_square_monies(lite_hash) }

    it 'mutates argument' do
      expect(lite_hash).to include(:price)
      expect(converted.object_id).to_not eq lite_hash.object_id
      expect(converted).to include(:price_money)
      expect(converted).to_not include(:price)
    end
  end
end
