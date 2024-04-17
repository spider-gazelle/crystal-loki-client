require "json"

module Loki::Model
  enum Status
    Success
    Fail
  end

  record LabelResponse, status : Status, data : Array(String)? do
    include JSON::Serializable
  end

  record Label, name : String, value : String do
    include JSON::Serializable
  end

  alias Labels = Array(Label)

  struct LabelSet
    include JSON::Serializable

    @[JSON::Field(ignore: true)]
    getter map = Hash(String, String).new

    protected def on_unknown_json_attribute(pull, key, key_location)
      map[key] = begin
        JSON::Any.new(pull).as_s
      rescue ex : ::JSON::ParseException
        raise ::JSON::SerializableError.new(ex.message, self.class.to_s, key, *key_location, ex)
      end
    end

    protected def on_to_json(json)
      map.each do |key, value|
        json.field(key) { value.to_json(json) }
      end
    end

    def to_s(io : IO) : Nil
      io << "{"
      sorted = map.keys.sort!
      io << sorted.map { |k| "#{k}=\"#{map[k]}\"" }.join(", ")
      io << "}"
    end
  end
end
