# frozen_string_literal: true

class SquareLite::Search
  class Base
    class << self
      attr_accessor :verb

      def expected_params
        @expected_params ||= []
      end

      def rename_param(mapping)
        rename_params[mapping.keys.first] = mapping.values.first
      end

      def rename_params
        @rename_params ||= {}
      end

      def const_missing(name)
        return SquareLite::Search.const_get(name) if SquareLite::Search.const_defined?(name)
        return SquareLite.const_get(name) if SquareLite.const_defined?(name)

        super(name)
      end

      def inherited(child)
        child.include(Enumerable)
        child.verb = :post
      end
    end

    attr_accessor :params, :verb
    attr_reader   :requester

    def initialize(requester, params={})
      @requester  = requester
      self.params = params.slice(*self.class.expected_params)
      self.params.merge!(rename_params(params))
    end

    def request
      validate!

      requester.request(self.class.verb, path, params: @params)
    end

    def each(&block)
      request.each(&block)
    end

    def fetch!
      request.to_a
    end

    def validate!; end

    protected

    def rename_params(params)
      mappings = self.class.rename_params

      result = params.slice(*mappings.keys)
      result.transform_keys! { |k| mappings[k] }
      result
    end

    def transition(to)
      to.new(@requester, params)
    end
  end
end
