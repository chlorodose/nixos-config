{
  lib,
  pkgs,
  config,
  ...
}:
{
  systemd.slices.system-database = { };
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17_jit;
    extensions =
      ps: with ps; [
        pg_cron
        timescaledb
      ];
    enableTCPIP = true;
    enableJIT = true;
    dataDir = "/srv/postgresql";
    authentication = lib.mkForce ''
      local all all   peer
    '';
    ensureUsers = [
      {
        name = "root";
        ensureClauses = {
          login = true;
          superuser = true;
          replication = true;
          createrole = true;
          createdb = true;
          bypassrls = true;
        };
      }
      {
        name = "postgres-exporter";
        ensureClauses.login = true;
      }
    ];
    settings = {
      shared_preload_libraries = [
        "pg_cron"
        "timescaledb"
        "pg_stat_statements"
      ];

      log_connections = true;
      log_statement = "ddl";
      logging_collector = true;
      log_disconnections = true;

      log_destination = lib.mkForce "syslog";
      log_line_prefix = "user=%u,db=%d,app=%a,client=%h ";

      max_connections = 1024;
      superuser_reserved_connections = 8;

      shared_buffers = "64GB";
      effective_cache_size = "128GB";
      max_prepared_transactions = 1024;
      work_mem = "128MB";
      maintenance_work_mem = "4GB";
      logical_decoding_work_mem = "4GB";

      max_stack_depth = "4MB";
      temp_file_limit = "4GB";

      # WAL
      max_wal_size = "64GB";
      checkpoint_completion_target = 0.9;
      wal_buffers = "16MB";
      wal_compression = "zstd";
      wal_init_zero = false;
      wal_recycle = false;

      # Disk
      random_page_cost = 1.6;
      effective_io_concurrency = 4;

      # Workers
      max_worker_processes = 72;
      max_parallel_workers = 72;
      max_parallel_workers_per_gather = 4;
      max_parallel_maintenance_workers = 32;

      # Extensions
      "cron.database_name" = "postgres";
      "cron.use_background_workers" = true;
      "timescaledb.enable_chunkwise_aggregation" = true;
      "timescaledb.vectorized_aggregation" = true;
      "timescaledb.enable_merge_on_cagg_refresh" = true;
      "timescaledb.max_background_workers" = 72;
      "timescaledb.license" = "timescale";
      "timescaledb.telemetry_level" = "off";
      "pg_stat_statements.max" = 4096;
      "pg_stat_statements.track" = "all";
    };
  };
  systemd.services = lib.listToAttrs (
    lib.map
      (value: {
        name = value;
        value = {
          serviceConfig.Slice = config.systemd.slices.system-database.name;
        };
      })
      [
        "postgresql"
      ]
  );
}
