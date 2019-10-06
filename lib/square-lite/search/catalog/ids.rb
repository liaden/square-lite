# frozen_string_literal: true

class SquareLite::Search::Catalog
  class Ids < Base
    include WithRelated

    self.verb = :post
    expected_params << :object_ids

    def path
      'v2/catalog/batch-retrieve'
    end
  end
end
