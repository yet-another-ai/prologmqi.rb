# frozen_string_literal: true

require 'test_helper'

class TestPrologMQI < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::PrologMQI::VERSION
  end

  def test_it_does_something_useful
    prolog = PrologMQI::PrologMQI.new
    prolog.session do |session|
      session.query("consult('#{fixture_prolog('friends')}')")
      session.query('assertz(likes(alice, bob))')
      session.query('assertz(likes(bob, alice))')

      assert session.query('likes(alice, bob)')
      assert session.query('likes(bob, alice)')
      assert_equal([{ 'X' => 'bob' }], session.query('likes(alice, X)'))
      assert_equal([{ 'X' => 'bob' }], session.query('friends(alice, X)'))
      assert_equal([{ 'X' => 'alice', 'Y' => 'bob' }, { 'X' => 'bob', 'Y' => 'alice' }], session.query('friends(X, Y)'))
    end
  end
end
