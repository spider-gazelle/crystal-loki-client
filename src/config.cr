require "http"
require "openssl"
require "./consts"

module Loki
  record ProxyConfig, username : String?, password : String?, url : String, skip_verify : Bool? do
    def self.from_env
      url = ENV["https_proxy"]? || ENV["http_proxy"]? || ENV["HTTPS_PROXY"]? || ENV["HTTP_PROXY"]?

      ProxyConfig.new(ENV["PROXY_USERNAME"]?, ENV["PROXY_PASSWORD"]?, url, ENV["PROXY_VERIFY_TLS"]?)
    end

    def parse
      uri = URI.parse(url)
      user = uri.user || username
      pass = uri.password || password
      host = uri.host.not_nil!                                          # ameba:disable Lint/NotNil
      port = uri.port || URI.default_port(uri.scheme.not_nil!).not_nil! # ameba:disable Lint/NotNil
      creds = {username: user, password: pass} if user && pass
      {host, port, creds}
    rescue
      raise "Malformed proxy url"
    end
  end

  class Client
    struct Config
      getter address : String
      getter username : String?
      getter password : String?
      getter ca_cert : Path?
      getter? tls_skip_verify : Bool
      getter client_cert : Path?
      getter key_path : Path?
      getter org_id : String?
      getter query_tags : String?
      getter bearer_token : String?
      getter bearer_token_file : String?
      getter auth_header : String?
      getter proxy : Loki::ProxyConfig?

      def initialize(@address, @username = nil, @password = nil, @ca_cert = nil, @tls_skip_verify = false, @client_cert = nil,
                     @key_path = nil, @org_id = nil, @query_tags = nil,
                     @bearer_token = nil, @bearer_token_file = nil, @auth_header = nil, @proxy = nil)
        if (@username.presence || @password.presence) && (@bearer_token.presence || @bearer_token_file.presence)
          raise Loki::ClientError.new("at most one of HTTP basic auth (username/password), bearer-token & bearer-token-file is allowed to be configured")
        end

        if (token = @bearer_token) && (bearer = @bearer_token_file)
          if token.size > 0 && bearer.size > 0
            raise Loki::ClientError.new("at most one of the options bearer-token & bearer-token-file is allowed to be configured")
          end
        end
      end

      def self.from_env
        ca = if cert = Loki::LOKI_CA_CERT_PATH
               Path[cert]
             end
        client = if cert = Loki::LOKI_CLIENT_CERT_PATH
                   Path[cert]
                 end
        key_path = if path = Loki::LOKI_CLIENT_KEY_PATH
                     Path[path]
                   end
        url = ENV["https_proxy"]? || ENV["http_proxy"]? || ENV["HTTPS_PROXY"]? || ENV["HTTP_PROXY"]?

        Config.new(Loki::LOKI_ADDR, Loki::LOKI_USERNAME, Loki::LOKI_PASSWORD, ca, Loki::LOKI_TLS_SKIP_VERIFY, client, key_path, Loki::LOKI_ORG_ID,
          Loki::LOKI_QUERY_TAGS, Loki::LOKI_BEARER_TOKEN, Loki::LOKI_BEARER_TOKEN_FILE, Loki::LOKI_AUTH_HEADER, url ? ProxyConfig.from_env : nil)
      end

      def tls_context : HTTP::Client::TLSContext?
        if (ca = @ca_cert) && (cert = @client_cert) && (key = @key_path)
          ctx = OpenSSL::SSL::Context::Client.from_hash({"key" => key.to_s, "cert" => cert.to_s, "ca" => ca.to_s})
          ctx.verify_mode = OpenSSL::SSL::VerifyMode::None if tls_skip_verify?
          ctx
        end
      end

      def bearer_token : String?
        if token = @bearer_token
          token
        elsif file = @bearer_token_file
          begin
            ::File.read(file)
          rescue
            raise Loki::ClientError.new("unable to read authorization credentials file #{file}")
          end
        else
          nil
        end
      end

      def req_headers
        result = [{"User-Agent", Loki::USER_AGENT}]
        # ameba:disable Lint/NotNil
        result << {auth_header.not_nil!, Base64.strict_encode("#{username}:#{password}")} if username && password
        result << {"X-Scope-OrgID", org_id.not_nil!} unless org_id.nil?        # ameba:disable Lint/NotNil
        result << {"X-Query-Tags", query_tags.not_nil!} unless query_tags.nil? # ameba:disable Lint/NotNil
        if token = bearer_token
          result << {"Bearer ", token}
        end
        result
      end
    end
  end
end
