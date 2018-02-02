module Correios
  module FindCep
    class Base < ActiveRecord::Base
      self.abstract_class = true
      self.table_name_prefix = 'correios_find_cep_'

      scope :having_unaccented, ->(col, val) { where("unaccent(#{col}) ILIKE unaccent(?)", val) }
    end
  end
end
