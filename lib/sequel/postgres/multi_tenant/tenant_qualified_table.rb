module Sequel
  module Postgres
    module MultiTenant
      class TenantQualifiedTable < Sequel::SQL::QualifiedIdentifier

        def initialize(tenant_selector, table)
          @tenant_selector = tenant_selector
          @column = table
        end

        def table
          @tenant_selector.current.to_s
        end

        to_s_method :qualified_identifier_sql, 'table, column'

      end
    end
  end
end