# frozen_string_literal: true

module SquareLite
  class InvalidSearchError < RuntimeError; end

  class MissingForTypeError < InvalidSearchError
    def initialize(msg='Complex searches require a catalog type')
      super(msg)
    end
  end

  class UnknownForTypeError < InvalidSearchError
    def initialize(types)
      super("Unknown types for search: #{types}")
    end
  end

  class UnknownOrderingError < InvalidSearchError
    def initialize(ordering)
      super("Unknown ordering: #{ordering}")
    end
  end

  class AmbiguousOrderingError < InvalidSearchError
    def initialize(ordering)
      super("Can only order by one attribute: #{ordering}")
    end
  end

  class TimeRangeError < InvalidSearchError
    def initialize(options)
      super("Ambiguous options: #{options}")
    end
  end

  class UnknownSourceError < InvalidSearchError
    def self.validate!(valid_items, selected_items, type)
      unknown_sources = selected_items - valid_items

      raise new("Unknown sources #{unknown_sources} specified for #{type}.") if unknown_sources.any?
    end
  end

  class TooFewError < InvalidSearchError
    def self.validate!(items, key, min)
      raise new("Too few items for #{key}: at least #{min}, got #{items.size}") if items.size < min
    end
  end

  class TooManyError < InvalidSearchError
    def self.validate!(items, key, max)
      raise new("Too many items for #{key}: at most #{max}, got #{items.size}") if items.size > max
    end
  end

  class MismatchedParams < InvalidSearchError
    def initialize(params)
      super(params.inspect)
    end
  end

  class EmptyRangeError < InvalidSearchError
    def initialize(range)
      super("Empty range specified: #{range}")
    end
  end
end
