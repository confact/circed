module Circed
  class LinkServer

    getter name : String
    getter target_host : String
    getter target_port : Int32

    getter socket : IPSocket? = nil

    @pingpong : Pingpong?

    @buffer : Array(String) = [] of String

    def initialize(name, target_host, target_port, password)
      @name = name
      @target_host = target_host
      @target_port = target_port

      @socket = TCPSocket.new(@target_host, @target_port)
      handshake(password)

      listen
    end

    def initialize(name, socket, password, buffer)
      @name = name
      @socket = socket
      @buffer = buffer
      @target_host = socket.peeraddr[2]
      @target_port = socket.peeraddr[1]

      listen
    end

    def handshake(password)
      # Implement the IRC handshake here...
      socket.puts "PASS #{password}"
      socket.puts "SERVER #{target_host} 0 :#{name}"

      setup([name])
    end

    def listen
      while !socket.not_nil!.closed?
        FastIRC.parse(socket.not_nil!) do |payload|
          case payload.command
          when "ERROR"
            handle_error(payload)
          when "PING"
            ping(payload.params)
          when "PONG"
            pong(payload.params)
          when "SERVER"
            setup(payload.params)
          when "PRIVMSG"
            handle_privmsg(payload)
          else
            puts "Unhandled command: #{payload.command}"
          end
        end

        if closed?
          puts "Socket closed, exiting..."
          break
        end
      end
    end

    def setup(params)
      @pingpong = Pingpong.new(self)
      @name = params[0]
      ServerHandler.add_server(self)
    end

    def pong(params : Array(String))
      @pingpong.try(&.pong(params))
      Log.debug { "PONG #{@nickname}" }
      # send_message("PING :#{@nickname} :localhost")
    end

    def ping(params : Array(String))
      @pingpong.try(&.ping(params))
      # return if @last_checked && @last_checked.not_nil! < 5.seconds.ago
    end

    def closed? : Bool
      socket.try(&.closed?) || false
    end
  end
end