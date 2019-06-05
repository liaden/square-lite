# frozen_string_literal: true

require 'logger'
require 'gem_config'

require_relative 'square-lite/client'
require_relative 'square-lite/search'
require_relative 'square-lite/version'

module SquareLite
  include GemConfig::Base

  def self.client(http_basic_auth: {}, access_token: ENV['SQUARE_ACCESS_TOKEN'])
    Client.new(http_bassic_auth: http_basic_auth) unless http_basic_auth.empty?
    Client.new(access_token: access_token)
  end

  def self.conf
    configuration
  end

  with_configuration do
    has :logger, default: Logger.new(STDOUT)
    has :log_level, values: %i[debug info warn fatal], default: :info
    has :temp_folder_path
    has :api_version
    has :timeout, default: 60
  end

  def self.debug?
    conf.log_level == :debug
  end

  CATALOG_TYPES = %w[
    ITEM
    ITEM_VARIATION
    CATEGORY
    DISCOUNT
    TAX
    MODIFIER
    MODIFIER_LIST
  ].map(&:freeze).freeze
end
