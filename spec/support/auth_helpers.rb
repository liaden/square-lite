# frozen_string_literal: true

def build_auth
  SquareLite::RequestBuilder::Auth.new(access_token: test_token)
end

def wm_auth
  { Authorization: "Bearer #{test_token}" }
end

def test_token
  ENV['TEST_SQUARE_ACCESS_TOKEN'] || default_test_token
end

def default_test_token
  'test-api-key'
end

def using_default_test_token?
  test_token == default_test_token
end
