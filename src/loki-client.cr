module Loki
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}

  class ClientError < Exception
  end

  enum Direction
    Forward
    Backward

    def to_s(io : IO)
      io << to_s.downcase
    end
  end
end

require "./**"
