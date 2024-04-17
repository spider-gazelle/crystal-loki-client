require "json"
require "./labels"

module Loki::Model
  struct Entry
    getter timestamp : Time?
    getter line : String?
    getter structred_metadata : Model::Labels?
    getter parsed : Model::Labels?
    @metadata : JSON::Any

    def initialize(@timestamp, @line, @structred_metadata, @parsed, @metadata = JSON::Any.new(nil))
    end

    def self.new(pull : ::JSON::PullParser)
      strs = Array(JSON::Any).new(pull)
      time = nil
      line = nil
      meta = nil
      parsed = nil
      metadata = nil
      strs.each_with_index do |val, idx|
        case idx
        when 0
          time = if val.as_s.size >= 10
                   Time.unix_ns(val.as_s.to_i64)
                 else
                   Time.unix(val.as_s.to_i64)
                 end
        when 1
          line = val.as_s
        when 2
          metadata = val
          hash = val.as_h
          if m = hash["structuredMetadata"]?
            meta = ::Union(Model::LabelSet | Nil).from_json(m.to_json).try &.map.map { |v| Model::Label.new(*v) }
          end
          if p = hash["parsed"]?
            parsed = ::Union(Model::LabelSet | Nil).from_json(p.to_json).try &.map.map { |v| Model::Label.new(*v) }
          end

          if meta.nil? && val.as_h?
            meta = ::Union(Model::LabelSet | Nil).from_json(val.to_json).try &.map.map { |v| Model::Label.new(*v) }
          end
        end
      end

      if m = metadata
        new(time, line, meta, parsed, m)
      else
        new(time, line, meta, parsed)
      end
    end

    def to_json(json : JSON::Builder)
      json.start_array
      json.string(timestamp.try &.to_unix_ns.to_s || "")
      json.string(line.to_s)
      @metadata.to_json(json) unless @metadata.raw.nil?
      json.end_array
    end
  end
end
