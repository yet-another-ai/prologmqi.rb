# frozen_string_literal: true

module PrologMQI
  class Parser
    def initialize(plain)
      @term = Term.new(JSON.parse(plain))
    end

    def parse
      handle_error
      resolve_content
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def handle_error
      return unless @term.name == 'exception'
      raise PrologError, @term unless @term.args && @term.args.length >= 1

      case @term.args[0]
      when 'no_more_results'
        nil
      when 'connection_failed'
        raise PrologConnectionFailedError, @term
      when 'time_limit_exceeded'
        raise PrologQueryTimeoutError, @term
      when 'no_query'
        raise PrologNoQueryError, @term
      when 'cancel_goal'
        raise PrologQueryCancelledError, @term
      when 'result_not_available'
        raise PrologResultNotAvailableError, @term
      else
        raise PrologError, @term
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity

    def resolve_content
      return false if @term.name == 'false'

      if @term.name == 'true'
        answers = []
        @term.args[0].each do |answer|
          next answers << true if answer.empty?

          answers << answer.to_h { |a| Term.new(a).args }
        end
        return true if answers == [true]

        return answers
      end
      @term
    end
  end
end
