# frozen_string_literal: true

require_relative 'generic_client'

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
    SquareLite::Search.new(*Array(options[:for]), as: generic_client)
  end

  private

  def generic_client
    SquareLite::GenericClient.new(@version, SquareLite::GenericClient::Auth.new(access_token: @access_token))
  end
end
