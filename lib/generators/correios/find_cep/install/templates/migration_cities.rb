class CorreiosCreateCorreiosFindCepCities < ActiveRecord::Migration<%= migration_version %>
  def up
    create_table :correios_find_cep_cities do |t|
      t.citext :uf
      t.citext :city
      t.integer :cep_min
      t.integer :cep_max

      t.timestamps
    end

    add_index :correios_find_cep_cities, :city
    add_index :correios_find_cep_cities, :cep_max, unique: true
    add_index :correios_find_cep_cities, :cep_min, unique: true
  end

  def down
    drop_table :correios_find_cep_cities
  end
end
