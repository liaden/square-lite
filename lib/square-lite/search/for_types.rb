# frozen_string_literal: true

class SquareLite::Search
  module ForTypes
    def for(*types)
      self. types = processed_types = types.map(&:to_s).map(&:upcase)

      if types == ['ORDER']
        # TODO
      elsif (unknown_types = processed_types - SquareLite::CATALOG_TYPES).any?
        raise SquareLite::UnknownForTypeError.new("Unknown types for search: #{unknown_types}")
      end

      self
    end
  end
end
