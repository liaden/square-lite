# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SquareLite::GenericClient::Auth do
  context 'http_basic_auth' do
  end

  context 'access_token_header' do
    it 'prepends "Bearer " to value' do
      auth = described_class.new(access_token: 'A')
      expect(auth.headers).to eq(Authorization: 'Bearer A')
    end

    it 'does not add duplicate "Bearer" to value' do
      auth = described_class.new(access_token: 'Bearer A')
      expect(auth.headers).to eq(Authorization: 'Bearer A')
    end
  end
end
