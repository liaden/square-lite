# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SquareLite::RequestBuilder do
  let(:version)  { '2.20190508.0' }
  let(:builder)  { SquareLite::RequestBuilder.new(version, build_auth) }
  let(:req)      { builder.build(:get, path) }
  let(:response) { req.run }
  let(:path)     { 'v2/catalog/info' }
  let(:json)     { JSON.parse(response.body) }

  context 'with network connection' do
    it 'can request catalog info' do
      skip if using_default_test_token?

      # stub_sq(path, version: version)
      WebMock.allow_net_connect!
      expect(test_token).to_not eq default_test_token
      expect(response.response_code).to eq 200
      expect(json).to include 'limits'
    ensure
      WebMock.disable_net_connect!
    end
  end
end
