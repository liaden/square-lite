# frozen_string_literal: true

class SquareLite::Create
  class IdValidator
    attr_reader :new_ids, :existing_ids

    def initialize(existing_ids, permit_double=nil)
      @existing_ids   = existing_ids
      @enforce_unique = !permit_double
      clear!
    end

    def validate!(*hashes)
      clear!
      validate(sanitize_and_check_hashes(hashes))
      true
    end

    def valid?
      validate!
    rescue SquareLite::UpsertError
      false
    end

    private

    def clear!
      @new_ids      = Set.new
      @updating_ids = Set.new
    end

    def sanitize_and_check_hashes(hashes)
      hashes = hashes.flatten

      raise SquareLite::UnknownTypeGivenError.new(hashes) unless hashes.all?(Hash)

      hashes
    end

    def validate(data)
      if data.is_a? Hash
        validate_id_key(data)
        validate_ids(slice_ids(data))
        data = data.values
      end

      data.each { |d| validate(d) if d.is_a?(Enumerable) }
    end

    def validate_ids(ids)
      ids.each do |id_name, value|
        Array(value).each do |id|
          raise SquareLite::EmptyIdError.new(id_name) unless id && id[0]

          if new_id?(id)
            validate_new(id)
          else
            validate_existing(id)
          end
        end
      end
    end

    def slice_ids(data)
      data.slice(*data.keys.grep(/_ids?$/))
    end

    def validate_new(id)
      raise SquareLite::NewIdAlreadyExistsError.new(id) if @existing_ids.include?(id)
    end

    def validate_existing(id)
      raise SquareLite::DanglingIdError.new(id) unless @existing_ids.include?(id)
    end

    def validate_uniqueness(id)
      return unless @enforce_unique

      ids = new_id?(id) ? @new_ids : @updating_ids
      raise SquareLite::DuplicateIdError.new(id) unless ids.add?(id)
    end

    def new_id?(id)
      id[0] == '#'
    end

    def validate_id_key(data)
      id = data[:id] || data['id'] || data[:ID] || data['ID']

      return unless id

      validate_ids(id: id)
      validate_uniqueness(id)
    end
  end
end
