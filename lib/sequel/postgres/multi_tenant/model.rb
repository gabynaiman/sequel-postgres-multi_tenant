module Sequel
  module Postgres
    module MultiTenant

      Model = Class.new(Sequel::Model) do

        def self.inherited(subclass)
          subclass.set_dataset db.tenant_qualified_table(subclass.implicit_table_name) if subclass.name
          super
        end

        def self.[](*args)
          args = args.first if args.size <= 1
          args.is_a?(Hash) ? where(args).first : (where(primary_key_hash(args)).first unless args.nil?)
        end

        def self.db=(db)
          super
          db.reload_dataset self
        end

        def self.eager(*args, &block)
          association_reflections.each_value do |assoc|
            assoc[:cache].clear if assoc.key? :cache
          end
          super
        end

      end

      def self.Model(table_name, &block)
        Class.new(Model, &block).tap do |subclass|
          subclass.set_dataset Model.db.tenant_qualified_table(table_name)
        end
      end

    end
  end
end