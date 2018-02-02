require 'correios/find_cep/scraper'
namespace :correios do
  namespace :find_cep do
    namespace :csv do
      desc 'Creates CSV at cwd with Cities CEP data'
      task scrap_cities: [:environment] do
        Correios::FindCep::Scraper.new(kind: 'csv').scrap_cities_table
      end

      desc 'Creates CSV at cwd with Cities and UFs CEP data'
      task scrap_cities_and_ufs: [:environment] do
        Correios::FindCep::Scraper.new(kind: 'csv').scrap_cities_and_ufs_tables
      end

      desc 'Creates CSV at cwd with UFs CEP data'
      task scrap_ufs: [:environment] do
        Correios::FindCep::Scraper.new(kind: 'csv').scrap_ufs_table
      end
    end

    namespace :database do
      desc 'Destroys all records from Correios::FindCep::City and repopulates the table'
      task scrap_cities: [:environment] do
        Correios::FindCep::Scraper.new(kind: 'database').scrap_cities_table
      end

      desc 'Destroys all records from Correios::FindCep::City and Correios::FindCep::Uf and repopulates the table'
      task scrap_cities_and_ufs: [:environment] do
        Correios::FindCep::Scraper.new(kind: 'database').scrap_cities_and_ufs_tables
      end

      desc 'Destroys all records from Correios::FindCep::Uf and repopulates the table'
      task scrap_ufs: [:environment] do
        Correios::FindCep::Scraper.new(kind: 'database').scrap_ufs_table
      end
    end
  end
end
