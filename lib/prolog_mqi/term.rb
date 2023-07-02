# frozen_string_literal: true

module PrologMQI
  class Term
    def initialize(term)
      @term = term
    end

    def functor?
      @term.is_a?(Hash) && @term.key?('functor') && @term.key?('args')
    end

    def array?
      @term.is_a?(Array)
    end

    def variable?
      @term.is_a?(String) && (@term[0].upcase == @term[0] || @term.start_with?('_'))
    end

    def atom?
      @term.is_a?(String) && !variable?
    end

    def name
      return @term if atom? || variable?

      @term['functor']
    end

    def args
      return nil unless @term.is_a?(Hash) && @term.key?('args')
      @term['args'].map do |arg|
        next nil if arg == 'nil'
        next arg.to_i if arg.is_a?(String) && arg.to_i.to_s == arg

        arg
      end
    end
  end
end
