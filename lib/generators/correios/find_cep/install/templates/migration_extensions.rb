class CorreiosEnableExtensionsCitextAndUnaccent < ActiveRecord::Migration<%= migration_version %>
  def change
    enable_extension 'citext'
    enable_extension 'unaccent'
  end
end
