# frozen_string_literal: true

module SquareLite::Converter
  module Money
    SQUARE_MONEY_ATTRS = %w[
      amount_money
      applied_money
      base_price_money
      buyer_tendered_money
      change_back_money
      discount_money
      gross_return_money
      gross_sales_money
      hourly_rate
      item_price_money
      price_money
      processing_fee_money
      service_charge_money
      tip_money
      total_discount_money
      total_money
      total_price_money
      total_service_charge_money
      total_tax_money
      variation_total_price_money
    ].to_set.freeze

    def self.to_square_money(money)
      { amount: money.cents, currency: money.currency.iso_code }
    end

    def self.from_square_money(data)
      ::Money.new(data['amount'] || data[:amount], data['currency'] || data[:currency])
    end

    def self.money_key(square_key)
      square_key.to_s.sub('_money', '')
    end

    def self.square_money_key(lite_key)
      "#{lite_key}_money" unless SQUARE_MONEY_ATTRS.include?(lite_key)
    end

    def self.from_square_monies(data)
      {}.tap do |result|
        SQUARE_MONEY_ATTRS.each_with_object(result) do |key, acc|
          money = data[key] || data[key.to_sym]

          acc[money_key(key)] = from_square_money(money) if money
        end
      end
    end

    def self.to_square_monies(data)
      {}.tap do |result|
        SQUARE_MONEY_ATTRS.each_with_object(result) do |key, acc|
          mkey  = money_key(key)
          money = data[mkey] || data[mkey.to_sym]

          acc[key.to_sym] = to_square_money(money) if money
        end
      end
    end

    def self.from_square_monies!(data)
      data.merge!(from_square_monies(data))
      data.reject! { |key, _| SQUARE_MONEY_ATTRS.include?(key) }
    end

    def self.to_square_monies!(data)
      data.merge!(to_square_monies(data))
      data.reject! { |key, _| SQUARE_MONEY_ATTRS.include?(money_key(key)) }
    end
  end
end
