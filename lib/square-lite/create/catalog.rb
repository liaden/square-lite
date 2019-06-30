# frozen_string_literal: true

# Batch Upsert
# * cannot have duplicates ids
# * cannot reference associated objects that won't be
#   created until subsequent batche (not enforced)
# * if not #new_id, it must exist in the catalog
# * update: must have current version
class SquareLite::Create
  class Catalog
    include SquareLite::Create::Commitable

    attr_reader :key

    def initialize(client, id_to_versions)
      @client     = client
      @objects    = []
      @id_to_vers = id_to_versions
    end

    def commit!(key: nil)
      @key = key || SecureRandom.uuid

      yield(self, @key) if block_given?

      validate!(@objects)

      params = {
        idempotency_key: @key,
        batches:         [{ objects: @objects }],
      }

      @response ||=
        begin
          request = @client.request(:post, 'v2/catalog/batch-upsert', paginate: false, params: params)
          request.run
        end

      JSON.parse(@response.body).tap do |json|
        raise SquareLite::ConnectAPIError.new(request, json['errors']) if json['errors']&.any?
      end
    end

    def clear!
      (instance_variables - %i[@client @ids]).each do |ivar|
        instance_variable_set(ivar, nil)
      end

      self
    end

    def category(data)
      data = data.attrs if data.respond_to?(:attrs)

      generate_id(data)
      add_to_batch(SquareLite::Converter::Catalog.to_category(data))
    end
    bulk_commitable :category, :categories

    def tax(data)
      data = data.attrs if data.respond_to?(:attrs)

      generate_id(data)
      add_to_batch(SquareLite::Converter::Catalog.to_tax(data))
    end
    bulk_commitable :category, :taxes

    def item(data)
      data = data.attrs if data.respond_to?(:attrs)

      raise SquareLite::UpdatingReadOnlyError.new(data, :product_type) if data[:product_type]

      generate_id(data)

      data.fetch(:variations, []).each do |variation|
        variation[:item_id] ||= data[:id]
        _variation(variation)
        SquareLite::VariationMismatchedItemIdError.validate!(variation, data)
      end

      add_to_batch(SquareLite::Converter::Catalog.to_item(data))
    end
    bulk_commitable(:item)

    def variation(data)
      data = data.attrs if data.respond_to?(:attrs)

      add_to_batch(_variation(data))
    end
    bulk_commitable(:variation)

    def discount(data)
      data = data.attrs if data.respond_to?(:attrs)

      generate_id(data)
      add_to_batch(SquareLite::Converter::Catalog.to_discount(data))
    end
    bulk_commitable(:discount)

    def modifier(data)
      data = data.attrs if data.respond_to?(:attrs)

      generate_id(data)
      add_to_batch(SquareLite::Converter::Catalog.to_modifier(data))
    end
    bulk_commitable(:modifier)

    private

    def add_to_batch(data)
      @objects << data
      data
    end

    def _variation(data)
      raise MissingItemId.new(data) unless data[:item_id]

      generate_id(data)

      SquareLite::Converter::Catalog.to_variation(data).tap do |r|
      end
    end

    def validate!(data)
      IdValidator.new(@id_to_vers.keys.to_set).validate!(data)
      VersionValidator.new(@id_to_vers).validate!(data)
      validate_object_count!(data)
    end

    def validate_object_count!(data)
      raise BatchTooBig.new(data.size, 10_000)      if data.size > 10_000
      raise 'TODO: Implement batch autoparitioning' if data.size > 1_000
    end

    def generate_id(data)
      data[:id] = "##{SecureRandom.uuid}" if data[:id].nil? || data[:id].empty?
    end

    # For autoparitioning batches
    # DEPENDENCY_GRAPH =
    #   {
    #     item: [ :category, :tax, :discount, :modifier_list_info ],
    #     category: [],
    #     modifier: [],
    #     modifier_list: [ :modifier, :modifier_override ],
    #     tax: []
    #     variation: [ :item, :measurement_unit ],
    #   }.freeze
  end
end
