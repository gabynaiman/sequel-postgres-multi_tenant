class User < Sequel::Model
end

class Country < Sequel::Postgres::MultiTenant::Model
  one_to_many :cities
end

class City < Sequel::Postgres::MultiTenant::Model
  many_to_one :country
end