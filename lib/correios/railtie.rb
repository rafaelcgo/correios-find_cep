module Correios
  module FindCep
    class Railtie < Rails::Railtie
      rake_tasks do
        load 'tasks/correios/find_cep/scrap_resultado_busca_faixa_CEP.rake'
      end
    end
  end
end
