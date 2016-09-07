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

  it 'Thread safe' do
    User.create name: 'user_1'
    assert_equal 1, User.count

    assert_database_error { Country.count }
    assert_database_error { City.count }

    threads = DB.tenants.map do |tenant|
      Thread.new do
        DB.using_tenant tenant do
          assert_equal 1, User.count

          1.upto(10) do |i|
            country = Country.create name: "Country (#{tenant}/#{i})"
            country.add_city name: "City (#{tenant}/#{i})"
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

end