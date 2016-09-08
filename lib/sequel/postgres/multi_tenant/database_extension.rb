module Sequel
  module Postgres
    module MultiTenant
      module DatabaseExtension

        def tenants
          select(:nspname)
            .from(:pg_namespace)
            .exclude(nspname: ['information_schema', 'public'])
            .exclude(Sequel.like(:nspname, 'pg_%'))
            .order(:nspname)
            .map { |row| row[:nspname].to_sym }
        end

        def create_tenant(tenant)
          create_schema tenant
        end

        def remove_tenant(tenant)
          drop_schema tenant, cascade: true
        end

        def current_tenant
          tenant_selector.current
        end

        def current_tenant=(tenant)
          tenant_selector.current = tenant
          reload_all_datasets
        end

        def using_tenant(tenant)
          synchronize do
            begin
              current = current_tenant
              self.current_tenant = tenant
              yield
            ensure
              self.current_tenant = current
            end
          end
        end

        def using_each_tenant
          tenants.each do |tenant|
            using_tenant tenant do
              yield tenant
            end
          end
        end

        def tenant_qualified_table(table_name)
          TenantQualifiedTable.new tenant_selector, table_name
        end

        def tenant_dataset(table_name)
          from(tenant_qualified_table(table_name))
        end

        def reload_dataset(model_class)
          model_class.set_dataset tenant_qualified_table(model_class.table_name.column)
        end

        def search_path
          self['SHOW SEARCH_PATH'].single_value
        end

        def search_path=(search_path)
          run "SET SEARCH_PATH = #{search_path}"
        end

        private

        def tenant_selector
          @tenant_selector ||= TenantSelector.new
        end

        def multi_tenant_models
          ObjectSpace.each_object(Class).select { |klass| klass < Sequel::Postgres::MultiTenant::Model && klass.db == self }
        end

        def reload_all_datasets
          if !@reloaded_datasets
            multi_tenant_models.each { |m| reload_dataset m }
            @reloaded_datasets = true
          end
        end

        def filter_schema(ds, opts)
          opts = opts.merge(schema: current_tenant) if current_tenant && !opts.key?(:schema)
          super ds, opts
        end

      end
    end
  end
end