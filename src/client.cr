require "connect-proxy"
require "http/headers"
require "http/request"
require "uri"

require "./consts"
require "./config"
require "./models/**"

module Loki
  class Client
    getter config : Config
    @http : ConnectProxy::HTTPClient

    def initialize(@config)
      uri = URI.parse(@config.address)
      @http = ConnectProxy::HTTPClient.new(uri, tls: @config.tls_context)
      if use_proxy = @config.proxy
        host, port, creds = use_proxy.parse
        proxy = ConnectProxy.new(host, port, creds)
        @http.set_proxy(proxy)
      end
    end

    def self.from_env
      Client.new(Config.from_env)
    end

    def query(query : String, limit : Int32 = 30)
      query(query, limit, Time.local, Loki::Direction::Backward)
    end

    def query(query : String, limit : Int32, time : Time, direction : Loki::Direction) : Loki::Model::QueryResponse
      params = {
        "query"     => query,
        "limit"     => limit.to_s,
        "time"      => time.to_unix_ns.to_s,
        "direction" => direction.to_s,
      }

      req = new_request("GET", url(Loki::QUERY_PATH, params))
      send_request(req, Loki::Model::QueryResponse)
    end

    def query_range(query : String, limit : Int32 = 30)
      end_time = Time.local
      start = end_time - 1.hour
      query_range(query, limit, start, end_time, Loki::Direction::Backward)
    end

    def query_range(query : String, limit : Int32, start : Time, end_time : Time, direction : Loki::Direction, step : Time::Span? = nil,
                    interval : Time::Span? = nil) : Loki::Model::QueryResponse
      params = {
        "query"     => query,
        "limit"     => limit.to_s,
        "start"     => start.to_unix_ns.to_s,
        "end"       => end_time.to_unix_ns.to_s,
        "direction" => direction.to_s,
      }

      params["step"] = step.seconds if step
      params["interval"] = interval.seconds if interval

      req = new_request("GET", url(Loki::QUERY_RANGE_PATH, params))
      send_request(req, Loki::Model::QueryResponse)
    end

    def list_labels(since : Time::Span = 1.hour) : Loki::Model::LabelResponse
      end_time = Time.local
      start = end_time - since
      list_labels(start, end_time)
    end

    def list_labels(start : Time, end_time : Time) : Loki::Model::LabelResponse
      params = {
        "start" => start.to_unix_ns.to_s,
        "end"   => end_time.to_unix_ns.to_s,
      }

      req = new_request("GET", url(Loki::LABELS_PATH, params))
      send_request(req, Loki::Model::LabelResponse)
    end

    def list_label_values(label : String, since : Time::Span = 1.hour) : Loki::Model::LabelResponse
      end_time = Time.local
      start = end_time - since
      list_label_values(label, start, end_time)
    end

    def list_label_values(name : String, start : Time, end_time : Time) : Loki::Model::LabelResponse
      params = {
        "start" => start.to_unix_ns.to_s,
        "end"   => end_time.to_unix_ns.to_s,
      }
      path = LABEL_VALUES_PATH % name
      req = new_request("GET", url(path, params))
      send_request(req, Loki::Model::LabelResponse)
    end

    def series(matches : Array(String) = Array(String).new, since : Time::Span = 1.hour)
      end_time = Time.local
      start = end_time - since
      series(matches, start, end_time)
    end

    def series(matches : Array(String), start : Time, end_time : Time) : Loki::Model::SeriesResponse
      matches = ["{}"] if matches.empty?

      params = {
        "start" => start.to_unix_ns.to_s,
        "end"   => end_time.to_unix_ns.to_s,
        "match" => matches,
      }
      req = new_request("GET", url(SERIES_PATH, params))
      send_request(req, Loki::Model::SeriesResponse)
    end

    def stats(query : String, since = 1.hour)
      end_time = Time.local
      start = end_time - since
      stats(query, start, end_time)
    end

    def stats(query : String, start : Time, end_time : Time) : Loki::Model::IndexStatsResponse
      params = {
        "start" => start.to_unix_ns.to_s,
        "end"   => end_time.to_unix_ns.to_s,
        "query" => query,
      }
      req = new_request("GET", url(STATS_PATH, params))
      send_request(req, Loki::Model::IndexStatsResponse)
    end

    private def url(suffix : String, params : Hash(String, String | Array(String)) | Nil = nil)
      base = config.address.strip("/")
      q = ""
      if p = params
        q = "?#{URI::Params.encode(p)}"
      end
      "#{base}#{suffix}#{q}"
    end

    private def new_request(method : String, url : String) : HTTP::Request
      headers = HTTP::Headers.new
      config.req_headers.each { |v| headers.add(*v) }
      HTTP::Request.new(method, url, headers)
    end

    private def send_request(req : HTTP::Request, clz : T.class) : T forall T
      req.headers.add("Accept", "application/json; charset=utf-8")

      # Check whether Content-Type is already set, Upload Files API requires
      # Content-Type set to multipart/form-data
      req.headers.add("Content-Type", "application/json; charset=utf-8") unless req.headers["Content-Type"]?
      resp = @http.exec(req)
      return T.from_json(resp.body) if resp.success?
      raise Loki::ClientError.new("Error returned: code: #{resp.status_code}, body: #{resp.body}")
    end
  end
end
