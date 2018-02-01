# Qyu::Store::Activerecord

[![Gem Version](https://img.shields.io/gem/v/qyu-store-activerecord.svg)](https://rubygems.org/gems/qyu-store-activerecord)
[![Build Status](https://travis-ci.org/FindHotel/qyu-store-activerecord.svg)](https://travis-ci.org/FindHotel/qyu-store-activerecord)

## Requirements:

* Ruby 2.4.0 or newer

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'qyu-store-activerecord'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install qyu-store-activerecord

## Configuration

To start using Qyu; you need a queue configuration and a state store configuration. Here's an example:
```ruby
Qyu.configure(
  queue: {
    type: :memory
    # Or one of the other production-ready queues available
    # Check https://github.com/FindHotel/qyu/wiki/Message-Queues
  },
  store: {
    type: :active_record,
    db_type: database_adapter,
    db_host: database_host,
    db_port: database_port,
    db_name: database_name,
    db_user: database_user,
    db_password: database_password,
    lease_period: 60
},
  # optional Defaults to STDOUT
  logger: Logger.new(STDOUT)
)
```

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/FindHotel/qyu-store-activerecord. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Qyu::Store::Activerecord project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/FindHotel/qyu-store-activerecord/blob/master/CODE_OF_CONDUCT.md).
