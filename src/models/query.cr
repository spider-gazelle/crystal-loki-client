require "json"
require "./labels"
require "./entry"
require "./stats"

module Loki::Model
  enum ResultType
    Streams
    Scalar
    Vector
    Matrix

    def to_s(io : IO) : Nil
      io << to_s.downcase
    end
  end

  alias Metric = Model::LabelSet
  alias Streams = Array(Stream)
  alias Vectors = Array(Vector)
  alias Matrix = Array(SampleStream)
  alias ResultValue = Streams | Vectors | Matrix | Scalar

  struct Scalar
    include JSON::Serializable

    getter value : Float64
    @[JSON::Field(converter: Time::EpochConverter)]
    getter timestamp : Time
  end

  struct Stream
    include JSON::Serializable

    @[JSON::Field(key: "stream")]
    getter labels : Model::LabelSet

    @[JSON::Field(key: "values")]
    getter entries : Array(Entry)
  end

  struct QueryResponseData
    include JSON::Serializable
    @[JSON::Field(key: "resultType")]
    getter result_type : ResultType
    @result : JSON::Any
    getter stats : Model::Stats

    def result : ResultValue?
      case result_type
      in ResultType::Streams then Streams.from_json(@result.to_json)
      in ResultType::Vector  then Vectors.from_json(@result.to_json)
      in ResultType::Matrix  then Matrix.from_json(@result.to_json)
      in ResultType::Scalar  then Scalar.from_json(@result.to_json)
      end
    end
  end

  struct QueryResponse
    include JSON::Serializable

    getter status : Model::Status
    @[JSON::Field(key: "data")]
    getter response_data : QueryResponseData
  end

  alias ValueType = Array(Float64 | String)
  record Vector, metric : Metric, value : ValueType do
    include JSON::Serializable

    def value : SamplePair
      SamplePair.new(@value)
    end
  end

  record SampleStream, metric : Metric, values : Array(ValueType) do
    include JSON::Serializable

    def value : Array(SamplePair)
      @value.map { |v| SamplePair.new(v) }
    end
  end

  struct SamplePair
    @values : Array(Float64 | String)

    def initialize(@values)
    end

    def timestamp : Time
      secs = @values.first.as(Float64)
      ss = secs.to_s
      if ss.to_s.index('.')
        u, s = ss.to_s.split('.')
        Time.unix(u.to_i) + s.to_f.seconds
      elsif ss.size > 10
        Time.unix_ns(secs.to_i64)
      else
        Time.unix(secs.to_i64)
      end
    end

    def value : Float64
      @values.last.as(String).to_f
    end
  end

  record SeriesResponse, status : String, data : Array(LabelSet) do
    include JSON::Serializable
  end

  record IndexStatsResponse, streams : UInt64, chunks : UInt64, bytes : UInt64, entries : UInt64 do
    include JSON::Serializable
  end
end
