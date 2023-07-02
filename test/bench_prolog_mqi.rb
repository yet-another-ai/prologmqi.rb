# frozen_string_literal: true

require 'test_helper'

class BenchPrologMQI < Minitest::Benchmark
  def bench_friends_query
    prolog = PrologMQI::PrologMQI.new
    prolog.session do |session|
      session.query("consult('#{fixture_prolog('friends')}')")
      session.query('assertz(likes(alice, bob))')
      session.query('assertz(likes(bob, alice))')
      assert_performance_linear 0.99 do |n|
        n.times do
          session.query('likes(alice, bob)')
          session.query('likes(bob, alice)')
          session.query('likes(alice, X)')
          session.query('friends(alice, X)')
          session.query('friends(X, Y)')
        end
      end
    end
  end

  # rubocop:disable Metrics/AbcSize
  def bench_revert_facts_instead_of_restart
    prolog = PrologMQI::PrologMQI.new
    n = 100

    time_no_restart = Benchmark.measure do
      prolog.session do |session|
        n.times do
          session.query("consult('#{fixture_prolog('friends')}')")
          session.query("unload_file('#{fixture_prolog('friends')}')")
        end
      end
    end

    time_restart = Benchmark.measure do
      n.times do
        prolog.session do |session|
          session.query("consult('#{fixture_prolog('friends')}')")
        end
      end
    end

    puts "bench_revert_facts_instead_of_restart\t#{time_no_restart.real}\t#{time_restart.real}"

    assert time_no_restart.real < time_restart.real
  end
  # rubocop:enable Metrics/AbcSize
end
