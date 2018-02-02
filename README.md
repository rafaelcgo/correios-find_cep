# Correios::FindCep

This gem scraps data from http://www.buscacep.correios.com.br/sistemas/buscacep/ResultadoBuscaFaixaCEP.cfm and saves records at a database from a Rails application (ActiveRecord). It can also write records to CSV file.

**Note that, to build the Cities table the gem will filter only records that "Tipo de Faixa" is "Total do município".**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'correios-find_cep'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install correios-find_cep

Copy the migrations with:

    $ rails generate correios:find_cep:install

Next you will need to migrate the database:

    $ rails db:migrate

Last step is to run the rake task:

    $ rails correios:find_cep:database:scrap_cities_and_ufs

You can check all available options with:

    $ rails -T | grep correios:find_cep

    rails correios:find_cep:csv:scrap_cities
    rails correios:find_cep:csv:scrap_cities_and_ufs
    rails correios:find_cep:csv:scrap_ufs
    rails correios:find_cep:database:scrap_cities
    rails correios:find_cep:database:scrap_cities_and_ufs
    rails correios:find_cep:database:scrap_ufs

## Usage

There are 2 available classes:

```ruby
Correios::FindCep::City
=> Correios::FindCep::City(id: integer, uf: string, city: string, cep_max: integer, cep_min: integer, created_at: datetime, updated_at: datetime)

Correios::FindCep::Uf
=> Correios::FindCep::Uf(id: integer, uf: string, cep_max: integer, cep_min: integer, created_at: datetime, updated_at: datetime)
```

UFs and Cities **are not unique**. Some cities and some UFs have more than one interval of associated CEPs. Also there are cities with the same name but at another UF.

Cities:

* Brasília - DF
* Nova Iguaçu - RJ
* São Paulo - SP

UFs:

* AM
* DF
* GO


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

For sake of simplicity (Correios website will be fetched only once) only generator tests have been implemented yet.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rafaelcgo/correios-find_cep.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

