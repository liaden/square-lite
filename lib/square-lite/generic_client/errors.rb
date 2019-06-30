# frozen_string_literal: true

module SquareLite
  class ConnectAPIError < RuntimeError
    attr_accessor :request, :errors

    def initialize(request, errors)
      @request = request
      @errors  = errors

      super("SquareConnect API returned errors:\n#{@errors.join("\n")}")
    end
  end
end
