# frozen_string_literal: true

class SquareLite::Create
  module Commitable
    module ClassMethods
      def commitable(method_name)
        define_method("#{method_name}!") do |data|
          commit! { |c| c.send(method_name, data) }
        end
      end

      def bulkable(method_name, plural=nil)
        plural ||= "#{method_name}s"
        define_method(plural) do |*hashes|
          hashes.map { |hash| send(method_name, hash) }
        end
      end

      def bulk_commitable(method_name, plural=nil)
        plural ||= "#{method_name}s"

        commitable(method_name)
        bulkable(method_name, plural)

        define_method("#{plural}!") do |*hashes|
          commit! { |c| hashes.each { |hash| c.send(method_name, hash) } }
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
