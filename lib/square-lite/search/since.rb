# frozen_string_literal: true

class SquareLite::Search
  module Since
    def since(datetime)
      params[:begin_time] = datetime.to_datetime.rfc3339
      self
    end

    def self.included(base)
      base.expected_params << :begin_time
    end
  end
end
