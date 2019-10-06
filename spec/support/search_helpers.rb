# frozen_string_literal: true

def build_search(type)
  SquareLite::Client.new(test_token).search.send(type)
end

def stub_search(resp=:default_resp)
  let!(:request) { stub_sq('v2/catalog/search', :post, resp.dup) }
end

# catalog specific
def prefix_query_params
  {
    object_types: ['ITEM'],
    query:        {
      prefix_query: {
        attribute_name:   'name',
        attribute_prefix: 'e',
      },
    },
  }
end
