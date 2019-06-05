# frozen_string_literal: true

class SquareLite::Search
  module WithRelated
    def with_related
      params[:include_related_objects] = true
      self
    end

    def self.included(base)
      base.expected_params << :include_related_objects
    end
  end
end
