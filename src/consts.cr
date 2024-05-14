module Loki
  QUERY_PATH          = "/loki/api/v1/query"
  QUERY_RANGE_PATH    = "/loki/api/v1/query_range"
  LABELS_PATH         = "/loki/api/v1/labels"
  LABEL_VALUES_PATH   = "/loki/api/v1/label/%s/values"
  SERIES_PATH         = "/loki/api/v1/series"
  TAIL_PATH           = "/loki/api/v1/tail"
  STATS_PATH          = "/loki/api/v1/index/stats"
  VOLUME_PATH         = "/loki/api/v1/index/volume"
  VOLUME_RANGE_PATH   = "/loki/api/v1/index/volume_range"
  DEFAULT_AUTH_HEADER = "Authorization"

  USER_AGENT = "crystal-loki-client/#{Loki::VERSION}"

  LOKI_ADDR     = ENV["LOKI_ADDR"]? || "http://loki:3100"
  LOKI_USERNAME = ENV["LOKI_USERNAME"]?
  LOKI_PASSWORD = ENV["LOKI_PASSWORD"]?

  LOKI_CA_CERT_PATH      = ENV["LOKI_CA_CERT_PATH"]?
  LOKI_TLS_SKIP_VERIFY   = ENV["LOKI_TLS_SKIP_VERIFY"]?.try { |v| v.downcase == "true" } || false
  LOKI_CLIENT_CERT_PATH  = ENV["LOKI_CLIENT_CERT_PATH"]?
  LOKI_CLIENT_KEY_PATH   = ENV["LOKI_CLIENT_KEY_PATH"]?
  LOKI_ORG_ID            = ENV["LOKI_ORG_ID"]?
  LOKI_QUERY_TAGS        = ENV["LOKI_QUERY_TAGS"]?
  LOKI_BEARER_TOKEN      = ENV["LOKI_BEARER_TOKEN"]?
  LOKI_BEARER_TOKEN_FILE = ENV["LOKI_BEARER_TOKEN_FILE"]?
  LOKI_AUTH_HEADER       = ENV["LOKI_AUTH_HEADER"]? || DEFAULT_AUTH_HEADER
end
