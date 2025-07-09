{
  config,
  outputs,
  pkgs,
  lib,
  ...
}:
{
  sops.secrets."matrix/token" = {
    sopsFile = outputs.lib.getSecret "services.yaml";
    mode = "0444";
  };
  services.prometheus = {
    rules =
      let
        makeRuleFile =
          args:
          (lib.toList (
            (lib.generators.toYAML { }) {
              groups = args;
            }
          ));
        makeRuleList = (
          lib.map (
            item:
            (
              item
              // {
                annotations = rec {
                  summary = item.annotations.summary;
                  detail = "value = {{ $value }}, labels = {{ $labels }}";
                  description = ''
                    <h1><font color="${
                      ({
                        critical = "red";
                        warning = "yellow";
                        info = "blue";
                      }).${item.labels.severity}
                    }">${summary}</font></h1>
                    <br><br>
                    <code>${detail}</code>
                  '';
                };
              }
            )
          )
        );
      in
      makeRuleFile [
        {
          name = "Availability";
          interval = "10s";
          rules = makeRuleList [
            {
              alert = "Prometheus Scrape Failed";
              expr = "up == 0";
              for = "30s";
              keep_firing_for = "5m";
              labels.severity = "critical";
              annotations.summary = "Prometheus[{{ $labels.instance }}.{{ $labels.job }}]抓取失败";
            }
            {
              alert = "Prometheus Alertmanager Disconnected";
              expr = "prometheus_notifications_alertmanagers_discovered < 1";
              for = "0s";
              labels.severity = "critical";
              annotations.summary = "Prometheus[{{ $labels.instance }}]无法连接到至少一个Alertmanager";
            }
            {
              alert = "Prometheus Rule Evaluation Failed";
              expr = "increase(prometheus_rule_evaluation_failures_total[30s]) > 0";
              for = "0s";
              keep_firing_for = "3m";
              labels.severity = "critical";
              annotations.summary = "Prometheus[{{ $labels.instance }}]规则评估失败";
            }
            {
              alert = "Prometheus Template Expansion Failed";
              expr = "increase(prometheus_template_text_expansion_failures_total[30s]) > 0";
              for = "0s";
              keep_firing_for = "3m";
              labels.severity = "critical";
              annotations.summary = "Prometheus[{{ $labels.instance }}]模板文本展开失败";
            }
            {
              alert = "Postgresql Down";
              expr = "pg_up == 0";
              for = "0s";
              keep_firing_for = "3m";
              labels.severity = "critical";
              annotations.summary = "Postgresql[{{ $labels.instance }}]宕机";
            }
            {
              alert = "Host Out of Memory";
              expr = "((node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100) < 10) and node_memory_MemAvailable_bytes < (2 * 1024 * 1024 * 1024)";
              for = "0s";
              keep_firing_for = "3m";
              labels.severity = "critical";
              annotations.summary = "主机[{{ $labels.instance }}]可用内存不足({{ $value }}%)";
            }
            {
              alert = "Host OOM Killed";
              expr = "increase(node_vmstat_oom_kill[10m]) > 0";
              for = "0s";
              labels.severity = "critical";
              annotations.summary = "主机[{{ $labels.instance }}]已被迫启动OOM杀手";
            }
            {
              alert = "Host Memory Error Correctable";
              expr = "increase(node_edac_correctable_errors_total[30s]) > 0";
              for = "0s";
              keep_firing_for = "3m";
              labels.severity = "info";
              annotations.summary = "主机[{{ $labels.instance }}.{{ $labels.controller }}]发生了可纠正的内存翻转";
            }
            {
              alert = "Host Memory Error Uncorrectable";
              expr = "increase(node_edac_uncorrectable_errors_total[30s]) > 0";
              for = "0s";
              keep_firing_for = "3m";
              labels.severity = "critical";
              annotations.summary = "主机[{{ $labels.instance }}.{{ $labels.controller }}]发生了可纠正的内存翻转";
            }
            {
              alert = "Host Out of Data Space";
              expr = "((node_filesystem_avail_bytes{mountpoint=\"/mnt\"} / node_filesystem_size_bytes{mountpoint=\"/mnt\"} * 100) < 10) and node_filesystem_avail_bytes{mountpoint=\"/mnt\"} < (8 * 1024 * 1024 * 1024)";
              for = "0s";
              keep_firing_for = "3m";
              labels.severity = "critical";
              annotations.summary = "主机[{{ $labels.instance }}]数据磁盘可用空间不足({{ $value }}%)";
            }
            {
              alert = "Host Out of Root Space";
              expr = "((node_filesystem_avail_bytes{mountpoint=\"/\"} / node_filesystem_size_bytes{mountpoint=\"/\"} * 100) < 25) and node_filesystem_avail_bytes{mountpoint=\"/\"} < (1 * 1024 * 1024 * 1024)";
              for = "0s";
              keep_firing_for = "3m";
              labels.severity = "critical";
              annotations.summary = "主机[{{ $labels.instance }}]根目录可用空间不足({{ $value }}%)";
            }
            {
              alert = "Service Failed";
              expr = "node_systemd_unit_state{state=\"failed\"} == 1";
              for = "0s";
              labels.severity = "critical";
              annotations.summary = "服务[{{ $labels.instance }}-{{ $labels.name }}]失败)";
            }
            {
              alert = "Disk Fail";
              expr = "smartctl_device_smart_status != 1";
              for = "0s";
              labels.severity = "critical";
              annotations.summary = "磁盘[{{ $labels.instance }}.{{ $labels.device }}]报告了故障";
            }
            {
              alert = "Disk Critical Warning";
              expr = "smartctl_device_critical_warning > 0";
              for = "0s";
              labels.severity = "critical";
              annotations.summary = "磁盘[{{ $labels.instance }}.{{ $labels.device }}]检测到严重警告";
            }
            {
              alert = "Disk Media Error";
              expr = "smartctl_device_media_errors > 0";
              for = "0s";
              labels.severity = "critical";
              annotations.summary = "磁盘[{{ $labels.instance }}.{{ $labels.device }}]检测到媒体错误";
            }
            {
              alert = "UPS On Battery";
              expr = "rate(network_ups_tools_battery_charge[30s]) < 0";
              for = "0s";
              labels.severity = "critical";
              annotations.summary = "UPS[{{ $labels.instance }}-{{ $labels.ups }}]正在使用电池供电";
            }
            {
              alert = "Postgresql Down";
              expr = "pg_up != 1";
              for = "0s";
              labels.severity = "critical";
              annotations.summary = "Postgresql[{{ $labels.instance }}]宕机";
            }
            {
              alert = "Postgresql Deadlock";
              expr = "increase(pg_stat_database_deadlocks[30s]) > 0";
              for = "0s";
              keep_firing_for = "3m";
              labels.severity = "warning";
              annotations.summary = "Postgresql[{{ $labels.instance }}.{{ $labels.datname }}]检测到死锁";
            }
            {
              alert = "Postgresql Out of Connections";
              expr = "((sum by (instance,job,server) (pg_stat_activity_count)) / (sum by (instance,job,server) (pg_settings_max_connections)) * 100) > 80";
              for = "0s";
              keep_firing_for = "3m";
              labels.severity = "critical";
              annotations.summary = "Postgresql[{{ $labels.instance }}.{{ $labels.datname }}]连接占用过多({{ $value }}%)";
            }
          ];
        }
        rec {
          name = "Performance";
          interval = "90s";
          rules = makeRuleList [
            {
              alert = "Prometheus Rule Slow Evaluation";
              expr = "max_over_time(prometheus_rule_group_last_duration_seconds[${interval}]) > prometheus_rule_group_interval_seconds";
              keep_firing_for = "10m";
              labels.severity = "warning";
              annotations.summary = "Prometheus[{{ $labels.instance }}]规则评估的花费时间超过了间隔时间({{ $value }}s)";
            }
            {
              alert = "Host CPU Pressure";
              expr = "(rate(node_pressure_cpu_waiting_seconds_total[${interval}]) * 100) > 50";
              keep_firing_for = "10m";
              labels.severity = "warning";
              annotations.summary = "主机[{{ $labels.instance }}]正处于CPU压力({{ $value }}%)";
            }
            {
              alert = "Host Memory Pressure";
              expr = "(rate(node_pressure_memory_waiting_seconds_total[${interval}]) * 100) > 30";
              keep_firing_for = "10m";
              labels.severity = "warning";
              annotations.summary = "主机[{{ $labels.instance }}]正处于内存压力({{ $value }}%)";
            }
            {
              alert = "Host IO Pressure";
              expr = "(rate(node_pressure_memory_waiting_seconds_total[${interval}]) * 100) > 50";
              keep_firing_for = "10m";
              labels.severity = "warning";
              annotations.summary = "主机[{{ $labels.instance }}]正处于IO压力({{ $value }}%)";
            }
            {
              alert = "Host IRQ Pressure";
              expr = "(rate(node_pressure_irq_waiting_seconds_total[${interval}]) * 100) > 75";
              keep_firing_for = "10m";
              labels.severity = "warning";
              annotations.summary = "主机[{{ $labels.instance }}]正处于IRQ压力({{ $value }}%)";
            }
            {
              alert = "Disk Over Heat";
              expr = "avg_over_time(smartctl_device_temperature{temperature_type=\"current\"}[${interval}]) > 65";
              for = "0s";
              keep_firing_for = "10m";
              labels.severity = "warning";
              annotations.summary = "磁盘[{{ $labels.instance }}.{{ $labels.device }}]过热({{ $value }}°C)";
            }
            {
              alert = "UPS Overload";
              expr = "avg_over_time(network_ups_tools_ups_load[${interval}]) > 80";
              for = "0s";
              keep_firing_for = "10m";
              labels.severity = "warning";
              annotations.summary = "UPS[{{ $labels.instance }}-{{ $labels.ups }}]高负载({{ $value }}%)";
            }
            {
              alert = "Postgres Cache Breakdown";
              expr = "((increase(pg_stat_database_blks_hit[${interval}])) / ((increase(pg_stat_database_blks_hit[${interval}])) + (increase(pg_stat_database_blks_read[${interval}]))) * 100) < 50";
              for = "0s";
              keep_firing_for = "10m";
              labels.severity = "warning";
              annotations.summary = "Postgresql[{{ $labels.instance }}.{{ $labels.datname }}]缓存被击穿({{ $value }}%)";
            }
            {
              alert = "Postgres High Rollback Rate";
              expr = "(increase(pg_stat_database_xact_rollback[90s]) / (increase(pg_stat_database_xact_rollback[90s]) + increase(pg_stat_database_xact_commit[90s])) * 100) > 5";
              for = "0s";
              keep_firing_for = "10m";
              labels.severity = "warning";
              annotations.summary = "Postgresql[{{ $labels.instance }}.{{ $labels.datname }}]事务高回滚率({{ $value }}%)";
            }
            {
              alert = "Host Time Out of Sync";
              expr = "(max_over_time(node_timex_maxerror_seconds[3m]) * 1000) > 1000";
              for = "3m";
              keep_firing_for = "10m";
              labels.severity = "info";
              annotations.summary = "主机[{{ $labels.instance }}]时间误差过大({{ $value }}ms)";
            }
          ];
        }
      ];
    alertmanager = {
      enable = true;
      listenAddress = "127.0.0.1";
      logFormat = "logfmt";
      webExternalUrl = "https://dashboard.chlorodose.me/alertmanager/";
      configuration.receivers = [
        {
          name = "default";
          webhook_configs = [
            {
              url = "http://127.0.0.1:${builtins.toString config.services.matrix-alertmanager.port}/alerts";
              http_config.basic_auth = {
                username = "alertmanager";
                password_file = config.sops.secrets."random-pass".path;
              };
            }
          ];
        }
      ];
      configuration.route = {
        receiver = "default";
      };
    };
    alertmanagers = [
      {
        scheme = "https";
        path_prefix = "/alertmanager";
        static_configs = [
          {
            targets = [
              "dashboard.chlorodose.me"
            ];
          }
        ];
      }
    ];
  };
  services.matrix-alertmanager = {
    enable = true;
    port = 9233;
    tokenFile = config.sops.secrets."matrix/token".path;
    secretFile = config.sops.secrets."random-pass".path;
    homeserverUrl = "https://matrix.chlorodose.me";
    matrixUser = "@system:matrix.chlorodose.me";
    matrixRooms = [
      {
        roomId = "!6AYkwtLSbCmvT4n5ZU:matrix.chlorodose.me";
        receivers = [
          "default"
        ];
      }
    ];
  };
  services.nginx.upstreams.alertmanager = {
    servers = {
      "${config.services.prometheus.alertmanager.listenAddress}:${builtins.toString config.services.prometheus.alertmanager.port}" =
        { };
    };
  };
  systemd.services.alertmanager.serviceConfig.Slice = config.systemd.slices.system-observability.name;
  systemd.services.matrix-alertmanager.serviceConfig.Slice =
    config.systemd.slices.system-observability.name;
}
