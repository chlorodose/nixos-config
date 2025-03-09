{ lib, pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17_jit;
    enableTCPIP = true;
    enableJIT = true;
    dataDir = "/srv/postgresql";
    authentication = lib.mkForce ''
      local all all   peer
    '';
    settings = {
      log_connections = true;
      log_statement = "all";
      logging_collector = true;
      log_disconnections = true;

      log_destination = lib.mkForce "syslog";
      log_line_prefix = "user=%u,db=%d,app=%a,client=%h ";

      max_connections = 1024;
      superuser_reserved_connections = 8;

      shared_buffers = "32GB";
      effective_cache_size = "96GB";
      max_prepared_transactions = 1024;
      work_mem = "32MB";
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
    };
  };
}
