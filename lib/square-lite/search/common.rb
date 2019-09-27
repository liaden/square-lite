# frozen_string_literal: true

class SquareLite::Search
  module Common
    attr_accessor :params, :verb
    attr_reader   :requester

    def initialize(requester, params)
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

    def rename_params(params)
      mappings = self.class.rename_params
      result = params.slice(*mappings.keys)
      result.transform_keys! { |k| mappings[k] }
      result
    end

    module ClassMethods
      def expected_params
        @expected_params ||= []
      end

      def rename_param(mapping)
        rename_params[mapping.keys.first] = mapping.values.first
      end

      def rename_params
        @rename_params ||= {}
      end

      attr_accessor :verb
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.include(Enumerable)
      base.verb = :post
    end
  end
end
