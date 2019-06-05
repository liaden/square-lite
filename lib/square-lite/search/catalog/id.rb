# frozen_string_literal: true

class SquareLite::Search::Catalog
  class Id
    include SquareLite::Search::Common
    include SquareLite::Search::WithRelated

    self.verb = :get

    def initialize(requester, params)
      super(requester, params)
      @object_id = params.delete(:object_id)
    end

    def path
      "v2/catalog/object/#{@object_id}"
    end
  end
end
