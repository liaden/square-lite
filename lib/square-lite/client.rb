# frozen_string_literal: true

require_relative 'generic_client'

class SquareLite::Client
  attr_accessor :access_token, :version, :default

  def enabled?
    @access_token != nil
  end

  def initialize(access_token)
    @access_token = access_token
    @version      = SquareLite::SQUARE_API_VERSION
  end

  def search(*resources)
    SquareLite::Search.new(generic_client).for(*resources)
  end

  def delete
    SquareLite::Delete.new(generic_client, search)
  end

  def create(resource=nil)
    SquareLite::Create.new(generic_client, search).for(resource)
  end

  private

  def generic_client
    SquareLite::GenericClient.paginated(@version, SquareLite::GenericClient::Auth.new(access_token: @access_token))
  end
end
