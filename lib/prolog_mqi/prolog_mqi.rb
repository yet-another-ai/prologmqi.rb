# frozen_string_literal: true

module PrologMQI
  class PrologMQI
    def initialize(timeout: 5)
      @timeout = timeout

      @process = nil
      @socket = nil
      @running = false
    end

    def running?
      @running
    end

    def session
      start unless running?
      yield self
    ensure
      stop if running?
    end

    def start
      raise LaunchError, 'PrologMQI is already running' if running?

      # Start prolog process
      @stdin, @stdout, @stderr, @process =
        Open3.popen3('swipl', '--quiet', '-g', 'mqi_start', '-t', 'halt', '--', '--write_connection_values=true',
                     '--create_unix_domain_socket=true')

      unix_domain_socket = @stdout.gets.chomp
      password = @stdout.gets.chomp

      # Create unix socket
      Timeout.timeout(@timeout) do
        @socket = UNIXSocket.new(unix_domain_socket)
      rescue Errno::ECONNREFUSED
        retry
      end

      # Authenticate
      @running = true
      write(password)
      read
    end

    def query(value)
      timeout_str = @timeout.nil? ? '_' : @timeout.to_s
      write("run(#{value}, #{timeout_str})")
      read
    end

    def query_async(value, find_all: true)
      timeout_str = @timeout.nil? ? '_' : @timeout.to_s
      find_all_str = find_all ? 'true' : 'false'
      write("run_async(#{value}, #{timeout_str}, #{find_all_str})")
      read
    end

    def cancel_query_async
      write('cancel_async')
      read
    end

    def query_async_result
      timeout_str = @timeout.nil? ? '-1' : @timeout.to_s
      write("async_result(#{timeout_str})")
      read
    end

    def halt_server
      write('halt')
      read
    end

    private

    def read
      bytesize = @socket.gets.chomp(".\n").to_i
      result = @socket.read(bytesize)
      Parser.new(result).parse
    end

    def write(value)
      message = "#{value}.\n"
      # FIXME: in PrologMQI major version 0,
      # the message length is count of Unicode code points, not bytes.
      bytesize = message.bytesize
      @socket.write("#{bytesize}.\n")
      @socket.write(message)
    end

    def stop
      halt_server
    ensure
      @socket.close
      @stdin.close
      @stdout.close
      @stderr.close
      @process.kill
      @running = false
    end
  end
end
