# frozen_string_literal: true

class SquareLite::Search
  module Ordered
    ORDERINGS = ['ASC', 'DESC'].freeze

    def sanitize_ordering(data, attribute_field_key_name)
      data = { data => 'DESC' } unless data.is_a?(Hash)

      ordering = data.values.first.to_s.upcase

      raise SquareLite::AmbiguousOrderingError.new(data.keys) if data.size > 1
      raise SquareLite::UnknownOrderingError.new(ordering) unless ORDERINGS.include?(ordering)

      { attribute_field_key_name => data.keys.first, :sort_order => ordering }
    end
  end
end
