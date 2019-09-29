# frozen_string_literal: true

class SquareLite::Search::Catalog
  class Ids
    include SquareLite::Search::Common

    self.verb = :post

    expected_params << :order_ids

    def path
      "v2/catalog/#{@location_id}/orders/batch-retrieve"
    end
  end
end
