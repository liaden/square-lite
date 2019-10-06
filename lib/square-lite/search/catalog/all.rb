# frozen_string_literal: true

class SquareLite::Search::Catalog
  class All < SquareLite::Search::Base
    include ForTypes

    expected_params << :types
    self.verb = :get

    def path
      'v2/catalog/list'
    end
  end
end
