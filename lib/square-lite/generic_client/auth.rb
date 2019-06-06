# frozen_string_literal: true

class SquareLite::GenericClient
  class Auth
    def initialize(access_token: nil)
      @access_token = access_token
    end

    def headers
      access_token_header
    end

    def access_token_header
      { Authorization: access_token_value }
    end

    private

    def access_token_value
      return @access_token if @access_token.start_with?('Bearer ')

      "Bearer #{@access_token}"
    end
  end
end
