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

  class EmptyRangeError < InvalidSearchError
    def initialize(range)
      super("Empty range specified: #{range}")
    end
  end
end
