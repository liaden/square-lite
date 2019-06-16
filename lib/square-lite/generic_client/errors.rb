# frozen_string_literal: true

module SquareLite
  class ConnectAPIError < RuntimeError
    attr_accessor :request, :errors

    def initialize(request, errors)
      @errors  = errors
      @request = request

      super("SquareConnect API returned errors:\n#{errors_list_string}")
    end

    def errors_list_string
      @errors.map(&:to_json).join("\n")
    end
  end
end
