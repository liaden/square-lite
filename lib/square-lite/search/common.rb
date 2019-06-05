# frozen_string_literal: true

class SquareLite::Search
  module Common
    attr_accessor :params, :verb
    attr_reader   :requester

    def initialize(requester, params)
      @requester  = requester
      self.params = params.slice(*self.class.expected_params)
    end

    def fetch!
      validate!

      JSON.parse(requester.build(self.class.verb, path, params: @params).run.body)
    end

    def validate!; end

    module ClassMethods
      def expected_params
        @expected_params ||= []
      end

      attr_accessor :verb
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.verb = :post
    end
  end
end
