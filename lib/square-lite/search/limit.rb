# frozen_string_literal: true

class SquareLite::Search
  module Limit
    def limit(val)
      params[:limit] = val
      self
    end

    def self.included(base)
      base.expected_params << :limit
    end
  end
end
