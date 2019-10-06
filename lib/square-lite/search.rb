# frozen_string_literal: true

class SquareLite::Search; end

require_relative 'search/errors'
require_relative 'search/base'
require_relative 'search/for_types'
require_relative 'search/with_related'
require_relative 'search/with_deleted'
require_relative 'search/since'
require_relative 'search/limit'
require_relative 'search/time_range'
require_relative 'search/ordered'

require_relative 'search/catalog'
require_relative 'search/orders'
require_relative 'search/customers'

class SquareLite::Search
  RESOURCES = %i[
    catalog
    transaction
    order
    customer
  ].to_set.freeze

  def initialize(client)
    @client = client
  end

  def for(*things)
    return self if things.empty?
    return catalog(*things) if things.size > 1
    raise SquareLite::UnknownForTypeError.new(things.first) unless respond_to?(things.first)

    public_send(things.first)
  end

  def all!(*resources)
    raise 'TODO'


    # hydra?
    # resources =
    #   if resources.any?
    #     RESOURCES.intersection(resources)
    #   else
    #     RESOURCES
    #   end
    #
    # RESOURCES.intersection(.flat_map do |resource|
    #   send(resource).all!
    # end
  end

  def id!(value, *values)
    raise 'TODO'

    # hydra?
    # RESOURCES.flat_map do |resource|
    #   send(resource).id!(value, *values)
    # end
  end

  def catalog(*things)
    Catalog.new(@client, *things)
  end

  def item
    Catalog.new(@client, :item)
  end

  def variant
    Catalog.new(@client, :variant)
  end

  def orders(at: nil)
    Orders.new(@client, at: Array(at))
  end

  def customers
    Customers.new(@client, {})
  end

  def location
    # TODO
  end

  def self.const_missing(const)
    SquareLite.const_get(const) if SquareLite.const_defined?(const)
  end
end
