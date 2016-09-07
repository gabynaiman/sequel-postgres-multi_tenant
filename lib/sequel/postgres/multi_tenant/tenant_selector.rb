module Sequel
  module Postgres
    module MultiTenant
      class TenantSelector

        PREFIX = 'sequel-multi_tenant-'.freeze

        def current=(tenant)
          Thread.current[key] = tenant
        end

        def current
          Thread.current[key]
        end

        private

        def key
          "#{PREFIX}#{object_id}"
        end

      end
    end
  end
end