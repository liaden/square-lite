# frozen_string_literal: true

class SquareLite::Search::Catalog
  class All
    include SquareLite::Search::Common
    include SquareLite::Search::ForTypes

    expected_params << :types
    self.verb = :get

    def path
      'v2/catalog/list'
    end

    def types=(val)
      params[:types] = val.join(',')
    end
  end
end
