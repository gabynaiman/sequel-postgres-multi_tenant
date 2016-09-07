require 'coverage_helper'
require 'minitest/colorin'
require 'pry-nav'
require 'logger'

require 'sequel-postgres-multi_tenant'

DB_NAME = 'sequel_postgres_multi_tenant_test'

public_db = Sequel.postgres user: 'postgres'

public_db.run "DROP DATABASE IF EXISTS #{DB_NAME}"
public_db.run "CREATE DATABASE #{DB_NAME}"

DB = Sequel.postgres user: 'postgres', database: DB_NAME

MIGRATOR = Sequel::Postgres::MultiTenant::Migrator.new DB, File.join(File.dirname(__FILE__), 'support', 'migrations')
MIGRATOR.migrate_all

Sequel::Model.db = DB

at_exit do
  DB.disconnect
  public_db.run "DROP DATABASE #{DB_NAME}"
end

require_relative 'support/models'

require 'minitest/autorun'