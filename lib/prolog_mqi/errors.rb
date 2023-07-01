# frozen_string_literal: true

module PrologMQI
  class Error < StandardError; end
  class PrologError < Error; end
  class LaunchError < Error; end
  class PrologQueryTimeoutError < PrologError; end
  class PrologConnectionFailedError < PrologError; end
  class PrologNoQueryError < PrologError; end
  class PrologQueryCancelledError < PrologError; end
  class PrologResultNotAvailableError < PrologError; end
end
