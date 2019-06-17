# frozen_string_literal: true

class SquareLite::Delete
  def initialize(client, search)
    @requester = client
    @search    = search
  end

  def customer(*ids, where: nil)
    check_parameters(ids, where)

    square_ids(where || id_query(ids)).each do |sqid|
      id_delete("v2/customers/#{sqid}")
    end
  end
  alias_method :customers, :customer

  def catalog_object(*ids, where: nil)
    check_parameters(ids, where)

    sqids = square_ids(where || id_query(ids))
    if sqids.size == 1
      id_delete("v2/catalog/object/#{sqids.first}")
    else
      batch_delete('v2/catalog/batch-delete', object_ids: sqids)
    end
  end
  alias_method :catalog_objects, :catalog_object

  private

  def check_parameters(ids, where)
    if ids.empty?
      raise NoDeletionCriteriaError.new if where.nil?
    elsif where # && ids.any?
      raise AmbiguousDeleteError.new
    end
  end

  def id_query(id, *ids)
    if ids.size == 1
      @search.id(id)
    elsif ids.size > 1
      @search.id(*ids)
    end
  end

  def square_ids(query)
    query.map { |obj| obj['id'] }.tap do |sqids|
      raise SquareLite::Delete::NoIdsError.new if sqids.empty?
      raise SquareLite::Delete::MissingIdError.new if sqids.any?(&:nil?)
    end
  end

  def id_delete(path)
    @requester.request(:delete, path).to_a
  end

  def batch_delete(path, params)
    @requester.request(:post, path, params: params).to_a
  end
end

require_relative 'delete/errors'
