require 'minitest_helper'

describe Sequel::Postgres::MultiTenant::Model do

  before do
    DB.create_tenant :test_model_1
    DB.create_tenant :test_model_2
    assert_equal [:test_model_1, :test_model_2], DB.tenants
    MIGRATOR.migrate_tenants
  end

  after do
    DB[:users].truncate
    DB.remove_tenant :test_model_1
    DB.remove_tenant :test_model_2
    assert_empty DB.tenants
  end

  def assert_database_error(&block)
    assert_raises Sequel::DatabaseError, &block
  end

  it 'Global models' do
    User.create name: 'user_1'
    assert_equal 1, User.count
          
    DB.using_each_tenant do |tenant|
      assert_equal 1, User.count
    end
  end

  it 'Thread safe relations' do
    assert_database_error { Country.count }
    assert_database_error { City.count }

    threads = DB.tenants.map do |tenant|
      Thread.new do
        DB.using_tenant tenant do
          1.upto(10) do |i|
            country = Country.create name: "Country (#{tenant}/#{i})"
            country.add_city name: "City (#{tenant}/#{i})"

            city = City.where(country_id: country.id).first

            assert_equal country, city.country

            binding.pry unless [city] == country.cities
            country.cities
            # assert_equal [city], country.reload.cities
          end
        end
      end
    end

    threads.each(&:join)

    DB.using_each_tenant do |tenant|
      expected_data = 1.upto(10).map { |i| {country: "Country (#{tenant}/#{i})", city: "City (#{tenant}/#{i})"} }
      actual_data = City.eager(:country).all.map { |c| {city: c.name, country: c.country.name} }

      assert_equal expected_data, actual_data
    end
  end

  it 'Subclass with table name' do
    model_class = Sequel::Postgres::MultiTenant::Model(:countries)

    assert_database_error { model_class.count }
    
    DB.using_each_tenant do |tenant|
      assert_equal 0, model_class.count
    end
  end

  it 'Change model db' do
    default_db = Sequel.postgres user: 'postgres'

    Country.db = default_db

    DB.using_each_tenant do |tenant|
      assert_database_error { Country.count }
    end

    Country.db = DB

    DB.using_each_tenant do |tenant|
      assert_equal 0, Country.count
    end
  end

  it 'Query single element' do
    user = User.create name: 'User'

    assert_equal user, User[user.id]
    assert_equal user, User[name: user.name]
    assert_nil User[nil]

    DB.using_tenant :test_model_1 do
      country = Country.create name: 'Argentina'

      assert_equal country, Country[country.id]
      assert_equal country, Country[name: country.name]
      assert_nil Country[nil]
    end
  end

end