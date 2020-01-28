# redash-query-replace

Command Line Tool to replace queries on Redash about query, data source, and so on.

## Example

```shell
## replace query which has id 5
$ redash-qr query --from 'database.table1' --to 'database.table2' --id 5

## replace all queries
$ redash-qr query --from 'database.table1' --to 'database.table2' --all

## replace data source the query id 5 has
$ redash-qr ds --from mysql_a --to mysql_b --query-id 5

## replace data source all queries have
$ redash-qr ds --from mysql_a --to mysql_b --all

```

## Usage

### Environment Variables

- **REDASH_URL**: Your Redash URL (required)
- **REDASH_API_KEY**: Your Redash Api Key (required)

You can also define then on `.env` file. (Ref. [dotenv doc](https://github.com/bkeepers/dotenv))

### `query` subcommand

Replace query text.

- **--exec**: Run actually. Dry run if this flag is no. (flag, default: no)
- **--from**: Replaced target regexp in query text (string, required)
- **--to**: Replacement string (string, required)
- **--id**: Query id. Either **--id** or **--all** option is required. (integer, optional)
- **--all**: The flag that all queries became replacement targets. Either **--id** or **--all** option is required. (flag, default: no)

### `ds` subcommand

Replace datasource queries have.

- **--exec**: Run actually. Dry run if this flag is no. (flag, default: no)
- **--from**: The replaced target datasource name (string, required)
- **--to**: Replacement datasource name (string, required)
- **--id**: Query id. Either **--id** or **--all** option is required. (integer, optional)
- **--all**: The flag that all queries became replacement targets. Either **--id** or **--all** option is required. (flag, default: no)


## Usage with docker

```
$ docker run --rm \
  -v `pwd`/:/vol \
  civitaspo/redash-qr query --from 'database.table1' --to 'database.table2' --id 5
```

## Change Log

See. [CHANGELOG.md](./CHANGELOG.md)

## License

See. [LICENSE.txt](./LICENSE.txt)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'redash-query-replace'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redash-query-replace
	
### Use Docker	

Build docker image on local
```
docker build -t ${USER}/redash-rp --build-arg REDASH_URL=<your redash url> --build-arg REDASH_API_KEY=<your redash api key>
```

Run docker image
```
docker run --rm -v `pwd`/:/vol ${USER}/redash-rp query --from 'database.table1' --to 'database.table2' --id 5
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/civitaspo/redash-query-replace. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the redash-query-replace project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/civitaspo/redash-query-replace/blob/master/CODE_OF_CONDUCT.md).
