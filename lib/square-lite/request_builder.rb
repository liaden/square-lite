# frozen_string_literal: true

require 'typhoeus'

module SquareLite
  class RequestBuilder
    attr_accessor :default_headers, :user_agent

    BASE_URL = 'https://connect.squareup.com/'

    def initialize(version, auth)
      self.user_agent = "Square-Connect-Ruby/#{version}"

      self.default_headers = {
        'Content-Type' => 'application/json',
        'User-Agent'   => @user_agent,
        'Accept'       => 'application/json',
      }.merge(auth.headers)
    end

    def build(http_method, path, opts={})
      url         = build_request_url(path)
      http_method = http_method.to_sym.downcase

      header_params = default_headers.merge(opts[:header_params] || {})

      req_opts = {
        method:         http_method,
        headers:        header_params,
        timeout:        opts[:timeout] || SquareLite.conf.timeout,
        ssl_verifypeer: 'true',
        ssl_verifyhost: 'true',
        verbose:        SquareLite.debug?,
      }

      if http_method == :get
        req_opts[:params] = opts[:params]
      else
        req_opts[:body] = build_request_body(opts[:params])
      end

      Typhoeus::Request.new(url, req_opts)
    end

    private

    def build_request_url(path)
      BASE_URL + path
    end

    def build_request_body(data)
      return if data.nil?

      data.to_json unless data.is_a?(String)
    end
  end
end

require_relative 'request_builder/auth'
