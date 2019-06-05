# frozen_string_literal: true

require_relative 'request_builder'

class SquareLite::Client
  attr_accessor :access_token, :version

  def enabled?
    @access_token != nil
  end

  def initialize(access_token)
    @access_token = access_token
    @version      = SquareLite::SQUARE_API_VERSION
  end

  def search(options={ for: [] })
    SquareLite::Search.new(*options[:for], as: request_builder)
  end

  private

  def request_builder
    SquareLite::RequestBuilder.new(@version, SquareLite::RequestBuilder::Auth.new(access_token: @access_token))
  end
end
