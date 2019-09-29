using SquareLite::HashUtils

class SquareLite::Search
  class Orders
    include SquareLite::Search::Common
    include SquareLite::Search::Limit
    include SquareLite::Search::Ordered

    yml_data = YAML.load_file('config/square/order.yml')

    STATUSES = yml_data[:states].freeze

    FULFILLMENT_TYPES  = yml_data[:fulfillment_types].freeze
    FULFILLMENT_STATES = yml_data[:fullfillment_states].freeze

    def initialize(requester, params={})
      location_ids = params.delete(:at) || params.delete('at')

      super(requester, params)

      locations(*location_ids) if Array(location_ids).any?
    end

    def locations(*locations)
      validate_size(:locations, locations, 1, 10)
      params[:location_ids] = locations
      self
    end
    alias_method :at, :locations

    def where(*vargs, **kwargs)
      vargs.each { |f| send(f) }

      kwargs.each do |f, data|
        data.is_a?(Hash) ? send(f, **data) : send(f, *data)
      end

      self
    end

    # Square API considers this to be `states`
    def status(*values)
      params.bury(:query, :filter, :state_filter, states: values)
      self
    end

    def open;      status(:open);      end
    def canceled;  status(:canceled);  end
    def completed; status(:completed); end

    def fulfillment(data)
      hash = {
        fulfillment_types:  Array(data.fetch(:types,  FULFILLMENT_TYPES)),
        fulfillment_states: Array(data.fetch(:states, FULFILLMENT_STATES)),
      }

      hash.transform_values! { |v| v.map(&:upcase) }

      params.bury(:query, :filter, :fulfillment_filter, hash)
      self
    end

    # there is no list of accepted values
    def from(*values)
      validate_size(:from, values, 1, 10)
      params.bury(:query, :filter, :source_filter, source_names: values)
      self
    end

    def customers(*values)
      validate_size(:customers, values, 1, 10)
      params.bury(:query, :filter, :customer_filter, customer_ids: values)
      self
    end

    # Square API requires ordering to match, thus we set it
    def closed(opts={})
      ordered(:closed)
      date_time_filter(:closed_at, time_range(opts[:on], opts[:during], opts[:since], opts[:until]))
      self
    end

    # Square API requires ordering to match, thus we set it
    def created(opts={})
      ordered(:created)
      date_time_filter(:created_at, time_range(opts[:on], opts[:during], opts[:since], opts[:until]))
      self
    end

    # Square API requires ordering to match, thus we set it
    def updated(opts={})
      ordered(:updated_at)
      date_time_filter(:updated_at, time_range(opts[:on], opts[:during], opts[:since], opts[:until]))
      self
    end

    # Square API requires ordering to match the date_time_filter so raise if disparity
    # Note: This also intentionally causes the error where we set one date_time_filter
    # and then another
    def ordered(data)
      data = sanitize_ordering(data, :sort_field)

      dtf = params.dig(:query, :filter, :date_time_filter) || {}
      if (dtf.keys - [data[:sort_field]]).any?
        raise SquareLite::MismatchedParams.new(sort_field: data, date_time_filter: dtf)
      end

      params.bury(:query, :sort, data)
      self
    end

    # return OrderEntry data instead of Order data
    def entries
      params[:return_entries] = true
      self
    end

    def path
      'v2/orders/search'
    end

    private

    # This is intended for validations when the key is defined in the hash
    def validate_size(key, items, min, max)
      SquareLite::TooFewError.validate!(items, key, min)
      SquareLite::TooManyError.validate!(items, key, max)
    end

    def date_time_filter(key, value)
      params.bury(:query, :filter, :date_time_filter, key, value)

      dtf = params.dig(:query, :filter, :date_time_filter)
      SquareLite::TooManyError.validate!(dtf.keys, :date_time_filter, 1)
    end

    def time_range(on, during, after, before)
      if before || after
        if on || during
          raise SquareLite::TimeRangeError.new(on: on, during: during, since: after, until: before)
        end

        after  ||= DateTime.new(2000, 1, 1)
        before ||= DateTime.now

        during = after..before
      end

      if on
        raise SquareLite::TimeRangeError.new(on: on, during: during) if during

        during = (on.to_date)..(on.to_date + 1)
      end

      raise SquareLite::EmptyRangeError.new(during) if during.first >= during.last

      { start_at: during.first, end_at: during.last }
    end
  end
end
