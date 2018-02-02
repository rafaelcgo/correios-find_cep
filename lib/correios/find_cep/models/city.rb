module Correios
  module FindCep
    class City < Correios::FindCep::Base
      self.table_name_prefix = 'correios_find_cep_'
    end
  end
end
