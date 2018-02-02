require 'rails/version'
require 'rails/generators'
require 'rails/generators/active_record/migration'

module Correios
  module FindCep
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)

      def copy_migration_files
        migration_template 'migration_extensions.rb', 'db/migrate/correios_enable_extensions_citext_and_unaccent.rb',
                           migration_version: migration_version
        migration_template 'migration_cities.rb', 'db/migrate/correios_create_correios_find_cep_cities.rb',
                           migration_version: migration_version
        migration_template 'migration_ufs.rb', 'db/migrate/correios_create_correios_find_cep_ufs.rb',
                           migration_version: migration_version
      end

      def rails5?
        Rails.version.start_with? '5'
      end

      def migration_version
        if rails5?
          "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
        end
      end
    end
  end
end
