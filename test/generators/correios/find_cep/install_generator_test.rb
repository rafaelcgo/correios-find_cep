require 'test_helper'
require 'generators/correios/find_cep/install/install_generator'

class Correios::FindCep::InstallGeneratorTest < Rails::Generators::TestCase
  tests Correios::FindCep::InstallGenerator
  destination 'tmp/generators'
  setup :prepare_destination

  test "generator runs without errors" do
    assert_nothing_raised do
      run_generator
    end
  end

  test "generator creates cities migration" do
    run_generator
    assert_migration 'db/migrate/correios_create_correios_find_cep_cities.rb', /#{migration_version}/
  end

  test "generator enable extensions migration" do
    run_generator
    assert_migration 'db/migrate/correios_enable_extensions_citext_and_unaccent.rb', /#{migration_version}/
  end

  test "generator creates ufs migration" do
    run_generator
    assert_migration 'db/migrate/correios_create_correios_find_cep_ufs.rb', /#{migration_version}/
  end

  def migration_version
    /\[5.\d+\]/ if generator.rails5?
  end
end
