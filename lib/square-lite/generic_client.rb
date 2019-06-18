# frozen_string_literal: true

require 'typhoeus'

module SquareLite
  class GenericClient
    attr_accessor :default_headers, :user_agent

    BASE_URL = 'https://connect.squareup.com/'

    def self.paginated(version, auth)
      new(version, auth).tap(&:auto_paginate!)
    end

    def initialize(version, auth)
      version ||= SquareLite::SQUARE_API_VERSION

      self.user_agent = "Square-Connect-Ruby/#{version}"

      self.default_headers = {
        'Content-Type' => 'application/json',
        'User-Agent'   => @user_agent,
        'Accept'       => 'application/json',
      }.merge(auth.headers)
    end

    def request(http_method, path, opts={})
      url      = build_request_url(path)
      paginate = opts.delete(:paginate)

      req_opts = {
        method:          http_method.to_sym.downcase,
        headers:         header_params(opts),
        timeout:         opts[:timeout] || SquareLite.conf.timeout,
        ssl_verifypeer:  'true',
        ssl_verifyhost:  'true',
        # https://github.com/typhoeus/typhoeus#compression
        accept_encoding: 'gzip',
        verbose:         SquareLite.debug?,
      }
      insert_params(req_opts, opts[:params])

      request = Typhoeus::Request.new(url, req_opts)
      return request unless paginate || auto_paginate?

      Cursor.new(request, opts[:params])
    end

    def auto_paginate!
      @paginate = true
    end

    def auto_paginate?
      @paginate
    end

    private

    def header_params(opts)
      default_headers.merge(opts[:header_params] || {})
    end

    def insert_params(req_opts, params)
      if req_opts[:method] == :get
        req_opts[:params] = params
      else
        req_opts[:body] = build_request_body(params)
      end
    end

    def build_request_url(path)
      BASE_URL + path
    end

    def build_request_body(data)
      return data if data.nil? || data.is_a?(String)

      data.to_json
    end
  end
end

require_relative 'generic_client/auth'
require_relative 'generic_client/cursor'
require_relative 'generic_client/errors'
