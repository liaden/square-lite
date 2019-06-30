# frozen_string_literal: true

module SquareLite::Converter
  module Catalog
    class << self
      def from_square_hash(data)
        return data.map(method(:from_square_hash)) if data.is_a?(Array)

        type   = data[:type]
        result = data.slice(*catalog_object_attrs)

        result.merge!(
          from_square_money(data),
          data[data_key(type)]
        )
      end

      def to_square_hash(type: nil, **data)
        result = data.slice(*catalog_object_attrs)

        result[:type]          = type
        result[data_key(type)] = data
          .slice(*nested_attrs[type.downcase.to_sym])
          .tap { |n| n[:percentage] = n[:percentage].to_digits if n[:percentage].respond_to?(:to_digits) }
          .merge!(to_square_money(data))

        result
      end

      def to_variation(data)
        to_square_hash(type: :ITEM_VARIATION, **data)
      end

      def to_item(data)
        to_square_hash(type: :ITEM, **data).tap do |result|
          result[:item_data][:variations] = data[:variations].map { |v| to_variation(v) } if data.key?(:variations)
        end
      end

      def to_tax(data)
        to_square_hash(type: :TAX, **data)
      end

      def to_category(data)
        to_square_hash(type: :CATEGORY, **data)
      end

      def to_discount(data)
        to_square_hash(type: :DISCOUNT, **data)
      end

      def to_modifier(data)
        to_square_hash(type: :MODIFIER, **data)
      end

      private

      def from_square_money(data)
        if data[:pricing_type] == :FIXED_PRICING
          SquareLite::Converter::Money.from_square_money(data[:price_money])
          price_money = data[:price_money]
          { price: Money.new(price_money[:amount], price_money[:currency]) }
        else
          {}
        end
      end

      def to_square_money(data)
        SquareLite::Converter::Money.to_square_monies(data)
      end

      def data_key(type)
        "#{type.downcase}_data".to_sym
      end

      def nested_attrs
        @nested_attrs ||=
          YAML.load_file('config/square/catalog.yml')[:nested_attrs].transform_values! { |attrs| attrs.map!(&:to_sym) }
      end

      def catalog_object_attrs
        @catalog_object_attrs ||= YAML.load_file('config/square/catalog.yml')[:catalog_object_attrs].map!(&:to_sym)
      end
    end
  end
end
