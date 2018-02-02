module Correios
  module FindCep
    class Uf < Correios::FindCep::Base
      self.table_name_prefix = 'correios_find_cep_'
    end
  end
end
