# crystal-loki-client

Crystal client library for accessing Grafana Loki APIs.

## Supported APIs

* `/loki/api/v1/query`
* `/loki/api/v1/query_range`
* `/loki/api/v1/labels`
* `/loki/api/v1/label/xxx/values`
* `/loki/api/v1/series`
* `/loki/api/v1/index/stats`


## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     loki-client:
       github: spider-gazelle/crystal-loki-client
   ```

2. Run `shards install`

## Usage

```crystal
require "loki-client"
```

You can configure the environment using the following variables or configure them via code.

* `LOKI_ADDR` - Loki Server address.
* `LOKI_USERNAME` - Username for HTTP basic auth.
* `LOKI_PASSWORD` - Password for HTTP basic auth.
* `LOKI_CA_CERT_PATH` - Path to the server Certificate Authority.
* `LOKI_TLS_SKIP_VERIFY` - Server certificate TLS skip verify.
* `LOKI_CLIENT_CERT_PATH` - Path to the client certificate.
* `LOKI_CLIENT_KEY_PATH` - Path to the client certificate key.
* `LOKI_ORG_ID` - adds X-Scope-OrgID to API requests for representing tenant ID. Useful for requesting tenant data when bypassing an auth gateway.
* `LOKI_QUERY_TAGS` - adds X-Query-Tags http header to API requests. Useful for tracking the query.
* `LOKI_BEARER_TOKEN` - adds the Authorization header to API requests for authentication purposes.
* `LOKI_BEARER_TOKEN_FILE` - adds the Authorization header to API requests for authentication purposes.
* `LOKI_AUTH_HEADER` - The authorization header used. Defaults to `Authorization`
* `https_proxy` or `http_proxy` - for proxy configuration 


```crystal
client = Loki::Client.from_env

# call endpoints
#
# client.query(my_query...)
# client.query_range(my_query ....)
# client.list_labels(since) # 1.hour ...
# ....
```

## Development



## Contributing

1. Fork it (<https://github.com/spider-gazelle/crystal-loki-client/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Contributors

- [Ali Naqvi](https://github.com/naqvis) - creator and maintainer
