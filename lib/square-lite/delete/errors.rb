# frozen_string_literal: true

class SquareLite::Delete
  class DeleteError < SquareLite::Error; end

  class NoDeletionCriteriaError < DeleteError
    def initialize
      super('Specify a query or id(s) to delete.')
    end
  end

  class AmbiguousDeleteError < DeleteError
    def initialize
      super('Conflicting arguments passed for deletion')
    end
  end

  class NoIdsError < DeleteError
    def initialize
      super('No IDs were specified for deletion request. Was your query wrong?')
    end
  end

  class MissingIdError < DeleteError
    def initialize
      super('Found nil instead of a Square ID')
    end
  end
end
