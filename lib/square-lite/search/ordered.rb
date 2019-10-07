# frozen_string_literal: true

class SquareLite::Search
  module Ordered
    ORDERINGS = %i[ASC DESC].freeze

    def sanitize_ordering(data, field_suffix: nil)
      if data.is_a?(Hash)
        raise SquareLite::AmbiguousOrderingError.new(data.keys) if data.size > 1

        field    = data.each_key.first.to_sym
        ordering = data[field].upcase.to_sym
        field    = field.upcase
      else
        field    = data.upcase.to_sym
        ordering = :DESC
      end

      if field_suffix && !field.to_s.end_with?(field_suffix.to_s)
        field = "#{field}_#{field_suffix}".to_sym
      end

      raise SquareLite::UnknownOrderingError.new(ordering) unless ORDERINGS.include?(ordering)

      [field, ordering]
    end
  end
end
