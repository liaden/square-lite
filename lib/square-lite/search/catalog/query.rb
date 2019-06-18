# frozen_string_literal: true

class SquareLite::Search::Catalog
  class Query
    include SquareLite::Search::Common
    include SquareLite::Search::ForTypes
    include SquareLite::Search::WithRelated
    include SquareLite::Search::WithDeleted
    include SquareLite::Search::Since
    include SquareLite::Search::Limit

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
      raise SquareLite::MissingForTypeError.new if no_object_types
    end

    def types=(val)
      params[:object_types] = val
    end
  end
end
