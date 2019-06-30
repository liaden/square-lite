# frozen_string_literal: true

class SquareLite::Create
  class VersionValidator
    def initialize(versions_by_ids)
      @versions_by_ids = versions_by_ids
    end

    def validate!(data)
      if data.is_a? Hash
        _validate(data) if data[:id]
        data = data.values
      end

      data.each { |value| validate!(value) } if data.is_a? Array

      true
    end

    private

    def _validate(data)
      return if new_id?(data[:id])

      raise SquareLite::MissingVersionError.new(data) unless data[:version]

      version         = data[:version]
      current_version = @versions_by_ids[data[:id]]

      raise SquareLite::StaleVersionError.new(data, current_version)      if version < current_version
      raise SquareLite::StaleVersionCacheError.new(data, current_version) if version > current_version
    end

    def new_id?(id)
      id[0] == '#'
    end
  end
end
