# frozen_string_literal: true

class SquareLite::Search::Catalog
  class Query < SquareLite::Search::Base
    include ForTypes
    include WithRelated
    include WithDeleted
    include Since
    include Limit

    expected_params << :object_types
    expected_params << :query

    def with_deleted
      params[:include_deleted_objects] = true
      self
    end

    def path
      'v2/catalog/search'
    end

    def validate!
      super

      no_object_types = params[:object_types].nil? || params[:object_types].empty?
      raise MissingForTypeError.new if no_object_types
    end

    def types=(val)
      params[:object_types] = val
    end
  end
end
