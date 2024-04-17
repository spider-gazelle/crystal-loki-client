require "json"

module Loki::Model
  record Stats, summary : Summary, querier : Querier, ingester : Ingester, cache : Caches do
    include JSON::Serializable
  end

  struct Summary
    include JSON::Serializable

    @[JSON::Field(key: "bytesProcessedPerSecond")]
    getter bytes_processed_per_second : Int64?

    @[JSON::Field(key: "linesProcessedPerSecond")]
    getter lines_processed_per_second : Int64?

    @[JSON::Field(key: "totalBytesProcessed")]
    getter total_bytes_processed : Int64?

    @[JSON::Field(key: "totalLinesProcessed")]
    getter total_lines_processed : Int64?

    @[JSON::Field(key: "execTime")]
    getter exec_time : Float64?

    @[JSON::Field(key: "queueTime")]
    getter queue_time : Float64?

    getter subqueries : Int64?

    @[JSON::Field(key: "totalEntriesReturned")]
    getter total_entries_returned : Int64?

    getter splits : Int64?
    getter shards : Int64?

    @[JSON::Field(key: "totalPostFilterLines")]
    getter total_post_filter_lines : Int64?

    @[JSON::Field(key: "totalStructuredMetadataBytesProcessed")]
    getter total_structured_metadata_bytes_processed : Int64?
  end

  record Querier, store : Store? do
    include JSON::Serializable
  end

  struct Store
    include JSON::Serializable

    @[JSON::Field(key: "totalChunksRef")]
    getter total_chunks_ref : Int64?

    @[JSON::Field(key: "totalChunksDownloaded")]
    getter total_chunks_downloaded : Int64?

    @[JSON::Field(key: "chunksDownloadTime")]
    getter chunks_downloaded_time : Int64?

    @[JSON::Field(key: "queryReferencedStructuredMetadata")]
    getter query_referenced_structured_metadata : Bool?

    getter chunk : Chunk?

    @[JSON::Field(key: "chunkRefsFetchTime")]
    getter chunk_refs_fetch_time : Int64?

    @[JSON::Field(key: "congestionControlLatency")]
    getter congestion_control_latency : Int64?
  end

  struct Chunk
    include JSON::Serializable

    @[JSON::Field(key: "headChunkBytes")]
    getter head_chunk_bytes : Int64?
    @[JSON::Field(key: "headChunkLines")]
    getter head_chunk_lines : Int64?
    @[JSON::Field(key: "decompressedBytes")]
    getter decompressed_bytes : Int64?
    @[JSON::Field(key: "decompressedLines")]
    getter decompressed_lines : Int64?
    @[JSON::Field(key: "compressedBytes")]
    getter compressed_bytes : Int64?
    @[JSON::Field(key: "totalDuplicates")]
    getter total_duplicates : Int64?
    @[JSON::Field(key: "postFilterLines")]
    getter post_filter_lines : Int64?
    @[JSON::Field(key: "headChunkStructuredMetadataBytes")]
    getter head_chunk_structured_metadata_bytes : Int64?
    @[JSON::Field(key: "decompressedStructuredMetadataBytes")]
    getter decompressed_structured_metadata_bytes : Int64?
  end

  struct Ingester
    include JSON::Serializable

    @[JSON::Field(key: "totalReached")]
    getter total_reached : Int32?

    @[JSON::Field(key: "totalChunksMatched")]
    getter total_chunks_matched : Int64?

    @[JSON::Field(key: "totalBatches")]
    getter total_batches : Int64?

    @[JSON::Field(key: "totalLinesSent")]
    getter total_lines_sent : Int64?

    getter store : Store
  end

  struct Cache
    include JSON::Serializable

    @[JSON::Field(key: "entriesFound")]
    getter entries_found : Int32?

    @[JSON::Field(key: "entriesRequested")]
    getter entries_requested : Int32?

    @[JSON::Field(key: "entriesStored")]
    getter entries_stored : Int32?

    @[JSON::Field(key: "bytesReceived")]
    getter bytes_received : Int64?

    @[JSON::Field(key: "bytesSent")]
    getter bytes_sent : Int64?

    getter requests : Int32?

    @[JSON::Field(key: "downloadTime")]
    getter download_time : Int64?

    @[JSON::Field(key: "queryLengthServed")]
    getter query_length_served : Int64?
  end

  struct Caches
    include JSON::Serializable
    getter chunk : Cache?
    getter index : Cache?
    getter result : Cache?

    @[JSON::Field(key: "statsResult")]
    getter stats_result : Cache?

    @[JSON::Field(key: "volumeResult")]
    getter volume_result : Cache?

    @[JSON::Field(key: "seriesResult")]
    getter series_result : Cache?

    @[JSON::Field(key: "labelResult")]
    getter label_result : Cache?

    @[JSON::Field(key: "instantMetricResult")]
    getter instant_metric_result : Cache?
  end
end
