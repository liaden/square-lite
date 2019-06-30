# frozen_string_literal: true

class SquareLite::GenericClient
  class Cursor
    include Enumerable

    attr_accessor :options

    def initialize(request, params=nil, options={})
      @request   = request
      @options   = options
      @params    = params || params_from_request
      @next_page = {}
    end

    def each(&block)
      return to_enum(:each) if block.nil?

      cursor = nil

      loop do
        results, related, cursor = next_page(cursor)

        results = Array(results)
        if yield_related
          related ||= {}
          results.each do |item|
            yield(item, related)
          end
        else
          results.each do |item|
            yield(item)
          end
        end

        break if cursor == ''
      end
    end

    def reload
      @next_page = {}
      delete_cursor_param
      self
    end

    private

    def next_page(cursor)
      return @next_page[cursor] if @next_page[cursor]

      results     = run_request(cursor)
      next_cursor = results.delete('cursor') || ''
      related     = related_objects(results.delete('related_objects'))
      resources   = results.values.first

      @next_page[cursor] = [resources, related, next_cursor]

      [resources, related, next_cursor]
    end

    def run_request(cursor)
      insert_cursor_param(cursor)
      JSON.parse(@request.run.body).tap do |data|
        errors = data.delete('errors') || []
        raise SquareLite::ConnectAPIError.new(@request, errors) if errors.any?
      end
    end

    def related_objects(related)
      related.group_by { |obj| obj['id'] } if related
    end

    def params_from_request
      if http_method == :get
        @request.options[:params] || {}
      else
        body = @request.options[:body]
        if body.is_a?(String)
          JSON.parse(body)
        else
          body || {}
        end
      end
    end

    def yield_related
      @params[:include_related_objects] || @params['include_related_objects']
    end

    def insert_cursor_param(cursor)
      return unless cursor

      @params['cursor'] = cursor
      set_req_params
    end

    def delete_cursor_param
      @params.delete('cursor')
      set_req_params
    end

    def set_req_params
      if http_method == :get
        @request.options[:params] = @params
      else
        @request.options[:body] = @params.to_json
      end
    end

    def http_method
      @request.options[:method]
    end
  end
end
