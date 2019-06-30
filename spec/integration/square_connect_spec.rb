# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SquareConnect API' do
  let(:client)  { SquareLite::Client.new(test_token) }
  let(:search)  { client.search(:catalog) }
  let(:catalog) { search.all }
  let(:creator) { client.create.catalog }

  before(:all) do
    WebMock.allow_net_connect!
  end

  after(:all) { WebMock.disable_net_connect! }

  it 'creates/reads/updates/deletes' do
    # create item and variation together
    response =
      creator.commit! do |c|
        c.item(name: 'test name', variations: [{ name: 'test_variation', price: Money.new(100, 'USD')}])
      end
    puts response

    # update item
    creator.commit! { |c| c.item(name: 'test name', description: 'test description') }

    # bigger creation batch within commit block
    creator.commit! do |c|
      c.tax      name: 'test-tax'
      c.category name: 'test-category'
    end

    # bigger creation batch of things
    create_alot = client.create.catalog
    create_alot.variation(
      name:    'test variation 2',
      pricing_type: :VARIABLE,
      item_id: create_alot.item(name: 'test name 2')[:id]
    )
    create_alot.commit!

    # read all items
    item    = catalog.first['item_data']
    item_id = catalog.first['id']

    # basic searches
    search.exactly(name: item['name'])
    search.id!(item_id)

    # extra flags
    search.with_deleted.with_related.exactly(name: item['name']).fetch!
  end
end if ENV['TEST_SQUARE_ACCESS_TOKEN']
