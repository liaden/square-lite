# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SquareLite::GenericClient do
  let(:version)  { '2.20190508.0' }
  let(:client)   { SquareLite::GenericClient.new(version, build_auth) }
  let(:req)      { client.request(:get, path) }
  let(:response) { req.run }
  let(:path)     { 'v2/catalog/info' }
  let(:json)     { JSON.parse(response.body) }

  describe '#request' do
    context 'paginate' do
      it 'returns an enumerable' do
        expect(client.request(:get, 'not/real', paginate: true)).to be_an(Enumerable)
      end

      it 'parses json to yield' do
        request = stub_sq('not/real', :get, body: { things: [{ name: :thing1 }] })
        client.request(:get, 'not/real', paginate: true).each do |item|
          expect(item).to eq('name' => 'thing1')
        end
        expect(request).to have_been_made
      end

      it 'can override auto_paginate' do
        client.auto_paginate!

        request = client.request(:get, 'not/real', paginate: false)

        expect(request).to_not be_an(Enumerable)
        expect(request).to_not be_nil
      end
    end

    it 'returns Typhoeus::Request' do
      expect(client.request(:get, 'not/real')).to be_a(Typhoeus::Request)
    end
  end

  describe '#auto_paginate' do
    it 'sets all requests to paginted' do
      client.auto_paginate!
      expect(client.request(:get, 'not/real')).to be_an(Enumerable)
    end
  end

  describe '#user_agent' do
    let(:version) { 'fake.version' }

    it 'sets square connect user agent' do
      expect(client.user_agent).to eq('Square-Connect-Ruby/fake.version')
    end
  end

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
