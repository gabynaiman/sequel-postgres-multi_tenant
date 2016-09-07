require 'minitest_helper'

describe Sequel::Postgres::MultiTenant::DatabaseExtension do

  before do
    DB.create_tenant :test_database
    MIGRATOR.migrate_tenant :test_database
    assert_equal [:test_database], DB.tenants
  end

  after do
    DB[:users].truncate
    DB.remove_tenant :test_database
    assert_empty DB.tenants
  end

  def assert_database_error(&block)
    assert_raises Sequel::DatabaseError, &block
  end

  it 'Tables' do
    assert_equal [:schema_info, :users], DB.tables.sort

    DB.using_tenant :test_database do
      assert_equal [:cities, :countries, :schema_info], DB.tables.sort
    end
  end

  it 'Datasets' do
    users = DB[:users]
    countries = DB.tenant_dataset(:countries)
    cities = DB.tenant_dataset(:cities)

    users.insert name: 'user_1'
    assert_equal 1, users.count

    assert_database_error { countries.count }
    assert_database_error { cities.count }

    DB.using_tenant :test_database do
      assert_equal 1, users.count

      country_id = countries.insert name: 'Argentina'
      assert_equal 1, countries.count

      cities.insert name: 'Buenos Aires', country_id: country_id
      assert_equal 1, cities.count

      expected_data = {country: 'Argentina', city: 'Buenos Aires'}
      actual_data = cities.join(countries.as(:countries), id: :country_id)
                   .select(:countries__name___country, :cities__name___city)
                   .first

      assert_equal expected_data, actual_data
    end
  end

end