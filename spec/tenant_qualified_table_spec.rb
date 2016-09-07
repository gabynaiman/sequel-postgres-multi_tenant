require 'minitest_helper'

describe Sequel::Postgres::MultiTenant::TenantQualifiedTable do

  it 'Tenant binded' do
    dataset = Sequel::Database.new.dataset
    tenant_selector = Sequel::Postgres::MultiTenant::TenantSelector.new
    tenant_qualified_table = Sequel::Postgres::MultiTenant::TenantQualifiedTable.new tenant_selector, :table_name

    tenant_selector.current = nil

    assert_equal '', tenant_qualified_table.table
    assert_equal :table_name, tenant_qualified_table.column
    assert_equal '""."TABLE_NAME"', tenant_qualified_table.sql_literal(dataset)

    tenant_selector.current = :tenant_name

    assert_equal 'tenant_name', tenant_qualified_table.table
    assert_equal :table_name, tenant_qualified_table.column
    assert_equal '"TENANT_NAME"."TABLE_NAME"', tenant_qualified_table.sql_literal(dataset)
  end

end