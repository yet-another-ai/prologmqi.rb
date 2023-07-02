# frozen_string_literal: true

require 'test_helper'

class TestPrologMQI < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::PrologMQI::VERSION
  end

  def test_prolog_would_not_start_twice
    prolog = PrologMQI::PrologMQI.new

    prolog.session do
      assert_raises(PrologMQI::LaunchError) { prolog.start }
    end
  end

  def test_friends
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

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def test_character
    prolog = PrologMQI::PrologMQI.new
    prolog.session do |session|
      session.query("consult('#{fixture_prolog('character')}')")
      session.query('assertz(current_hour(7))')
      session.query('assertz(character(woody))')
      session.query('assertz(character_state(woody, idling))')
      session.query('assertz(character_hungriness(woody, 10))')
      session.query('assertz(character_tiredness(woody, 30))')
      session.query('assertz(item(cake))')
      session.query('assertz(item(cigarettes))')
      session.query('assertz(food(cake))')
      session.query('assertz(has(woody, cake))')
      session.query('assertz(finds(woody, cigarettes))')
      session.query('assertz(likes(woody, cigarettes))')

      assert_equal([
                     { 'C' => 'woody', 'A' => 'sleep', 'I' => nil },
                     { 'C' => 'woody', 'A' => 'pick', 'I' => 'cigarettes' },
                     { 'C' => 'woody', 'A' => 'eat', 'I' => 'cake' }
                   ], session.query('make_decision(C, A, I)'))
      assert_equal([{ 'X' => 30 }], session.query('character_tiredness(woody, X)'))
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def test_fish
    prolog = PrologMQI::PrologMQI.new
    prolog.session do |session|
      session.query("consult('#{fixture_prolog('fish')}')")

      assert_equal([{ 'X' => 'germany' }, { 'X' => 'germany' }], session.query('fish(X)'))
      assert_equal(
        [
          { 'X' => [{ 'args' => %w[norway water hockey cat yellow], 'functor' => 'h' },
                    { 'args' => %w[denmark tea baseball horse blue], 'functor' => 'h' },
                    { 'args' => %w[britain milk polo bird red], 'functor' => 'h' },
                    { 'args' => %w[sweden beer billiards dog white], 'functor' => 'h' },
                    { 'args' => %w[germany coffee soccer fish green], 'functor' => 'h' }] },
          { 'X' => [{ 'args' => %w[norway water hockey cat yellow], 'functor' => 'h' },
                    { 'args' => %w[denmark tea baseball horse blue], 'functor' => 'h' },
                    { 'args' => %w[britain milk polo bird red], 'functor' => 'h' },
                    { 'args' => %w[germany coffee soccer fish green], 'functor' => 'h' },
                    { 'args' => %w[sweden beer billiards dog white], 'functor' => 'h' }] }
        ], session.query('houses(X)')
      )
    end
  end
end
