# frozen_string_literal: true

def stub_sq(path, *opts, version: nil, headers: {}, body: nil, status: 200)
  stub_request(_verb_from(opts), sq_url(path)).tap do |req|
    req.with(headers: stub_headers(version: version, overrides: headers))

    if opts.include?(:default_resp)
      req.to_return(sq_resp(status: status))
    elsif !body.nil?
      req.to_return(sq_resp(body, status: status))
    end
  end
end

def sq_resp(body={}, status: 200, headers: {})
  { body: body.to_json, headers: headers, status: status }
end

# expect the request body is a superset of params
def expect_req_body(request, params)
  request.with do |r|
    if r.body
      expect(JSON.parse(r.body)).to include(params)
    else
      expect(params).to be_nil
    end
  end
end

def json_headers
  { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
end

def ua_headers(version)
  version ||= SquareLite::SQUARE_API_VERSION
  { 'User-Agent' => "Square-Connect-Ruby/#{version}" }
end

def stub_headers(version: nil, overrides: {})
  json_headers
    .merge('Expect' => '')
    .merge(wm_auth)
    .merge(ua_headers(version))
    .merge(overrides)
end

def _verb_from(opts)
  %i[get post put delete].each do |v|
    return v if opts.include?(v)
  end

  :get
end

def sq_url(path)
  "https://connect.squareup.com/#{path}"
end
