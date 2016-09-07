require 'pg'
require 'sequel'
require 'sequel/adapters/postgres'

require_relative 'sequel/postgres/multi_tenant/version'
require_relative 'sequel/postgres/multi_tenant/tenant_selector'
require_relative 'sequel/postgres/multi_tenant/tenant_qualified_table'
require_relative 'sequel/postgres/multi_tenant/model'
require_relative 'sequel/postgres/multi_tenant/database_extension'
require_relative 'sequel/postgres/multi_tenant/migrator'

Sequel::Postgres::Database.send :include, Sequel::Postgres::MultiTenant::DatabaseExtension

Sequel.extension :migration