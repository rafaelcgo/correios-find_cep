class CorreiosCreateCorreiosFindCepUfs < ActiveRecord::Migration<%= migration_version %>
  def up
    create_table :correios_find_cep_ufs do |t|
      t.citext :uf
      t.citext :state
      t.integer :cep_min
      t.integer :cep_max

      t.timestamps
    end

    add_index :correios_find_cep_ufs, :uf
    add_index :correios_find_cep_ufs, :cep_max, unique: true
    add_index :correios_find_cep_ufs, :cep_min, unique: true
  end

  def down
    drop_table :correios_find_cep_ufs
  end
end
