module Sequel
  module Postgres
    module MultiTenant
      class Migrator

        GLOBAL_PATH  = 'global'.freeze
        TENANTS_PATH = 'tenants'.freeze

        attr_reader :db, :migrations_path

        def initialize(db, migrations_path)
          @db = db
          @migrations_path = migrations_path
        end

        def migrate_global(options={})
          run File.join(migrations_path, GLOBAL_PATH), options
        end

        def migrate_tenant(tenant, options={})
          search_path = db.search_path
          db.search_path = tenant
          run File.join(migrations_path, TENANTS_PATH), options
          db.search_path = search_path
        end

        def migrate_tenants(options={})
          db.tenants.each { |t| migrate_tenant t, options }
        end
        
        def migrate_all(options={})
          migrate_global
          migrate_tenants
        end

        private

        def run(migrations_path, options)
          Sequel::Migrator.run db, migrations_path, options
        end

      end
    end
  end
end