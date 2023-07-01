# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'prolog_mqi'

require 'minitest/autorun'

def fixture_prolog(name)
  File.join(__dir__, "fixtures/#{name}.pl")
end
