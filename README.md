# SquareLite

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/square/lite`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'square-lite'
```

## Usage

Basic Usage:
```ruby
require 'square-lite'

# override default configuration if desired
SquareLite.configure do |config|
  config.logger = Rails.logger # Logger.new(STDOUT)
  config.timeout = 10
end

# search for an item
SquareLite.client.search(for: :item).id('SQUARE_ITEM_ID').map { ... }
```

### Typhoeus Configuratio
Typhoeus has global configuration and per request configuration.

### Barebones Client
`SquareLite::GenericClient` provides a simple interface to wrap standard headers and access token to build a `Typhoeus::Request`.

### Authorization
Currently limited to using an access token. The gem will pull this from the environment variable `SQUARE_ACCESS_TOKEN` or it can be set when constructing the client instance: `SquareClient.client(access_token: 'TOKEN')`

### Searching

Currently, only the catalog related objects are searchable.

 * `run`: Returns an enumerator that handles pagination.
 * `fetch!`: Loads all data
 * `search`: Entry point for search query. Takes `for: a_type` or `for: [:type1, :type2]`
 * `for`: Specify the type via method instead of in the `search` method.
 * `id`: takes 1+ identifies
 * `all`: lists all items in the catalog
 * `starts_with(attr_name: :pre)`: matches `attr_name` with values such as `prefix` and `prehistoric`
 * `excactly(attr_name: :value)`: Exact match of attribute name.
 * `within(attr_name: start_val..end_val)`: Finds matches for within the range. `-Infinity` and `Infinity` can be used.
 * `at_most(attr_name: value)`: Inclusive match where everything less than or equal is returned.
 * `at_least(attr_name: value)`: Inclusive match where everything greater than or equal is returned.
 * `ordered(attr_name: :asc)`: Sorts records based on attr_name, either `ASC` or `DESC`. Can be invoked as `ordered(attr_name)` and defaults to `DESC`.
 * `limit(num)`: Request only `num` records to be returned. Square doesn't promise they won't return more, I think.
 * `since(1.day.ago)`: Returns only objects that have been **modified** since specified time.
 * `with_deleted`: Allows catalog queries to return back deleted objects. Does not work for `id` or `all`.
 * `with_related`: Returns assocaiated objects of other types with the matching records.

### Pagination

If the result set is too big, Square will paginate the data.

`SquareLite::GenericClient.paginate` will build the generic client in a way that handles pagination of the pages lazily. `SquareLite::Client` uses `GenericClient.paginate`. Additionally, request data for the request is cached locally in memory so additional iteration over the cursor will not incur additional network requests.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/liaden/square-lite.

### Planned Functionality (Eventually)

* Catalog deletion/upsert
* [Customers](https://developer.squareup.com/docs/api/connect/v2#navsection-customers)
* [Inventory](https://developer.squareup.com/docs/api/connect/v2#navsection-inventory)
* [Orders](https://developer.squareup.com/docs/api/connect/v2#navsection-orders)
* [Transactions](https://developer.squareup.com/docs/api/connect/v2#navsection-transactions)

### Unplanned Functionality

These are pieces I'm  rest is functionality that I don't plan on implementing, but I am more than happy taking pull requests:

* [ApplePay](https://developer.squareup.com/docs/api/connect/v2#navsection-applepay)
* [Checkout](https://developer.squareup.com/docs/api/connect/v2#navsection-checkout)
* [Employees](https://developer.squareup.com/docs/api/connect/v2#navsection-employees)
* [Labor](https://developer.squareup.com/docs/api/connect/v2#navsection-labor)
* [Reporting](https://developer.squareup.com/docs/api/connect/v2#navsection-reporting)



## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
