# frozen_string_literal: true

module SquareLite
  class UpsertError < RuntimeError; end
  class BadId < UpsertError; end

  class NewIdAlreadyExistsError < BadId
    def initialize(id)
      super("New ID already exists: #{id}")
    end
  end

  class DanglingIdError < BadId
    def initialize(id)
      super("Specified ID does not exist: #{id}")
    end
  end

  class EmptyIdError < BadId
    def initialize(id_name)
      super("ID attribute #{id_name} is an empty ('')")
    end
  end

  class DuplicateIdError < BadId
    def initialize(id)
      super("ID #{id} has already been specified once")
    end
  end

  class UnknownTypeGivenError < BadId
    def initialize(data)
      super("Unknown Type: Cannot validate data=#{data}")
    end
  end

  class VariationMismatchedItemIdError < UpsertError
    def self.validate!(variation, item)
      raise new(variation, item) unless variation[:item_id] == item[:id]
    end

    def initialize(variation, item)
      terse_variation = variation.slice(:name, :id, :item_id)
      terse_item      = item.slice(:name, 'name', :id, 'id')

      super("Item Id != Id: Variation = #{terse_variation}; Item = #{terse_item}")
    end
  end

  class MissingItemIdError < UpsertError
    def initialize(data)
      super("Variation #{data.slice(:id, :name)} is missing :item_id")
    end
  end

  class BatchTooBigError < UpsertError
    def initialize(batch_size, max_size)
      super("#{batch_size - max_size} objects passed in excess of #{max_size} for catalog upsert")
    end
  end

  class MissingVersionError < UpsertError
    def initialize(data)
      super("Missing version for #{data.slice(:id, :name, :type)}")
    end
  end

  class StaleVersionError < UpsertError
    def initialize(data, current_version)
      super("Version #{data[:version]} < #{current_version} for #{data.slice(:id, :name, :type)}")
    end
  end

  class StaleVersionCacheError < UpsertError
    def initialize(data, current_version)
      super("Version #{data[:version]} > #{current_version} for #{data.slice(:id, :name, :type)}. Is the cache stale?")
    end
  end

  class UpdatingReadOnlyError < UpsertError
    def initialize(data, *attrs)
      super("Attempted to update read only data:\n#{data.slice(:name, :id, :type, *attrs)}")
    end
  end
end
