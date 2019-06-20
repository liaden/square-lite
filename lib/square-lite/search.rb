# frozen_string_literal: true

class SquareLite::Search; end

require_relative 'search/errors'
require_relative 'search/common'
require_relative 'search/for_types'
require_relative 'search/with_related'
require_relative 'search/with_deleted'
require_relative 'search/since'
require_relative 'search/limit'

require_relative 'search/catalog'
require_relative 'search/order'

class SquareLite::Search
  include SquareLite::Search::Common
  include SquareLite::Search::ForTypes
  include SquareLite::Search::WithRelated
  include SquareLite::Search::WithDeleted
  include SquareLite::Search::Since
  include SquareLite::Search::Limit

  def self.id!(val, **context)
    new(**context).id!(val)
  end

  def initialize(*types, **context)
    as(context[:as])
    self.for(*types)
  end

  def id(value, *values)
    if values.any?
      SquareLite::Search::Catalog::Ids.new(@client, params.merge(object_ids: [value] + values))
    else
      SquareLite::Search::Catalog::Id.new(@client, params.merge(object_id: value))
    end
  end

  def id!(value, *values)
    id(value, *values).fetch!
  end

  def all
    SquareLite::Search::Catalog::All.new(@client, params)
  end

  def all!
    all.fetch!
  end

  def as(client)
    @client = client
  end

  def types=(val)
    @types =
      if val.empty?
        SquareLite::CATALOG_TYPES
      else
        val
      end

    params[:types]        = @types.join(',')
    params[:object_types] = @types
  end

  def starts_with(data)
    query(:prefix_query,
          attribute_name:   data.keys.first,
          attribute_prefix: data.values.first)
  end

  def exactly(data)
    query(:exact_query,
          attribute_name:  data.keys.first,
          attribute_value: data.values.first)
  end

  def within(data)
    range = data.values.first
    raise SquareLite::EmptyRangeError.new(range) if range.first >= range.last

    if range.first.infinite?
      query(:sorted_attribute_query,
            attribute_name:          data.keys.first,
            initial_attribute_value: range.last,
            sort_order:              'DESC')
    elsif range.last.infinite?
      query(:sorted_attribute_query,
            attribute_name:          data.keys.first,
            initial_attribute_value: range.first,
            sort_order:              'ASC')
    else
      query(:range_query,
            attribute_name:      data.keys.first,
            attribute_min_value: range.first,
            attribute_max_value: range.last)
    end
  end

  def at_most(data)
    query(:sorted_attribute_query,
          attribute_name:          data.keys.first,
          sort_order:              'DESC',
          initial_attribute_value: data.values.first)
  end

  def at_least(data)
    query(:sorted_attribute_query,
          attribute_name:          data.keys.first,
          sort_order:              'ASC',
          initial_attribute_value: data.values.first)
  end

  def ordered(data)
    data = { data => 'DESC' } unless data.is_a?(Hash)

    ordering = data.values.first.to_s.upcase
    raise SquareLite::AmbiguousOrderingError.new(data.keys) if data.size > 1
    raise SquareLite::UnknownOrderingError.new(data.values.first) unless ['ASC', 'DESC'].include?(ordering)

    query(:sorted_attribute_query,
          attribute_name: data.keys.first,
          sort_order:     data.values.first.to_s.upcase)
  end

  def params
    @params ||= {}
  end

  private

  def query(search_type, search_params)
    search_params = params.merge(query: { search_type => search_params })
    SquareLite::Search::Catalog::Query.new(@client, search_params)
  end
end
