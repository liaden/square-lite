# frozen_string_literal: true

RSpec.describe SquareLite::Converter::Catalog do
  describe 'to_square format' do
    subject(:run_convert) { described_class.send("to_#{resource}", attrs) }
    let(:attrs) { { name: "test-#{resource}" } }

    describe '.to_category' do
      let(:resource) { :category }

      it { is_expected.to include(category_data: { name: 'test-category' }) }
      it { is_expected.to include(type: :CATEGORY) }
      it { expect { run_convert }.to_not(change { attrs.hash }) }
    end

    describe '.to_tax' do
      let(:resource) { :tax }

      it { is_expected.to include(tax_data: { name: 'test-tax' }) }
      it { is_expected.to include(type: :TAX) }
      it { expect { run_convert }.to_not(change { attrs.hash }) }
    end

    describe '.to_discount' do
      let(:resource) { :discount }

      let(:discount_type) { :FIXED_PERCENTAGE }

      before { attrs.merge!(discount_type: discount_type, pin_required: true) }
      before { attrs.merge!(percentage: BigDecimal('7.5')) if discount_type == :FIXED_PERCENTAGE }

      context 'fixed percentage' do
        it { is_expected.to include(discount_data: include(discount_type: :FIXED_PERCENTAGE)) }
        it { is_expected.to include(discount_data: hash_excluding(:amount_money)) }
        it { is_expected.to include(discount_data: include(percentage: '7.5')) }
      end

      context 'variable amount' do
        let(:discount_type) { :VARIABLE_AMOUNT }

        it { is_expected.to include(discount_data: include(discount_type: :VARIABLE_AMOUNT)) }
        it { is_expected.to include(discount_data: hash_excluding(:amount_money)) }
        it { is_expected.to include(discount_data: hash_excluding(:percantage)) }
      end

      context 'variable percentage' do
        let(:discount_type) { :VARIABLE_PERCENTAGE }

        it { is_expected.to include(discount_data: include(discount_type: :VARIABLE_PERCENTAGE)) }
        it { is_expected.to include(discount_data: hash_excluding(:amount_money)) }
        it { is_expected.to include(discount_data: hash_excluding(:percentage)) }
      end

      context 'fixed amount' do
        let(:discount_type) { :FIXED_AMOUNT }

        before { attrs.merge!(amount: Money.new(500, 'USD')) }

        it { is_expected.to include(discount_data: include(discount_type: :FIXED_AMOUNT)) }
        it { is_expected.to include(discount_data: include(amount_money: { amount: 500, currency: 'USD' })) }
        it { is_expected.to include(discount_data: hash_excluding(:percantage)) }
      end

      it { is_expected.to include(discount_data: include(name: 'test-discount')) }
      it { is_expected.to include(type: :DISCOUNT) }
      it { expect { run_convert }.to_not(change { attrs.hash }) }
    end

    describe '.to_item' do
      let(:resource) { :item }

      it { is_expected.to include(item_data: { name: 'test-item' }) }
      it { is_expected.to include(type: :ITEM) }
      it { is_expected.to include(item_data: hash_excluding(:variations)) }
      it { expect { run_convert }.to_not(change { attrs.hash }) }

      context 'with nested variation' do
        let(:variation_data) { { name: 'test-variation', item_id: '#new-item' } }
        before { attrs.merge!(id: '#new-item', variations: [variation_data]) }

        let(:expected_item_data) do
          { item_data: hash_including(variations: [hash_including(item_variation_data: variation_data)]) }
        end

        it { is_expected.to include(expected_item_data) }
      end
    end

    describe '.to_variation' do
      let(:resource) { :variation }

      before { attrs.merge!(pricing_type: :VARIABLE_PRICING) }

      it { is_expected.to include(item_variation_data: include(name: 'test-variation')) }
      it { is_expected.to include(item_variation_data: include(pricing_type: :VARIABLE_PRICING)) }
      it { is_expected.to include(item_variation_data: hash_excluding(:price_money)) }
      it { is_expected.to include(type: :ITEM_VARIATION) }
      it { expect { run_convert }.to_not(change { attrs.hash }) }

      context 'fixed pricing' do
        before { attrs.merge!(pricing_type: :FIXED_PRICING, price: Money.new(100, 'USD')) }

        it { is_expected.to include(item_variation_data: include(price_money: { amount: 100, currency: 'USD' })) }
        it { is_expected.to include(item_variation_data: include(pricing_type: :FIXED_PRICING)) }
      end
    end
  end
end
