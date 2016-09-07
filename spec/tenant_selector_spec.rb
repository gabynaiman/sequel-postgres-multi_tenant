require 'minitest_helper'

describe Sequel::Postgres::MultiTenant::TenantSelector do
  
  it 'Thread safe' do
    selector_1 = Sequel::Postgres::MultiTenant::TenantSelector.new
    selector_2 = Sequel::Postgres::MultiTenant::TenantSelector.new

    assert_nil selector_1.current
    assert_nil selector_2.current

    selector_1.current = :t1
    selector_2.current = :t2

    assert_equal :t1, selector_1.current
    assert_equal :t2, selector_2.current

    thread = Thread.new do
      assert_nil selector_1.current
      assert_nil selector_2.current

      selector_1.current = :x1
      selector_2.current = :x2

      assert_equal :x1, selector_1.current
      assert_equal :x2, selector_2.current
    end

    thread.join

    assert_equal :t1, selector_1.current
    assert_equal :t2, selector_2.current
  end

end