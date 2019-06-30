# frozen_string_literal: true

require 'set'
require 'securerandom'

module SquareLite
  class Create
    def initialize(client, search)
      @search    = search
      @requester = client
    end

    def for(resource=nil)
      return self unless resource

      public_send(resource)
    end

    def catalog
      id_to_version = @search.catalog.all.each_with_object({}) { |obj, id_map| id_map[obj['id']] = obj['version'] }

      Create::Catalog.new(@requester, id_to_version)
    end
  end
end

require_relative 'create/errors'
require_relative 'create/commitable'
require_relative 'create/id_validator'
require_relative 'create/version_validator'

require_relative 'create/catalog'
