# frozen_string_literal: true

class SquareLite::Search
  module WithDeleted
    def with_deleted
      params[:include_deleted_objects] = true
      self
    end

    def self.included(base)
      base.expected_params << :include_deleted_objects
    end
  end
end
