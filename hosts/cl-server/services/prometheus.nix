{
  config,
  outputs,
  pkgs,
  lib,
  ...
}:
{
  boot.kernel.sysctl."kernel.perf_event_paranoid" = 0;
  systemd.slices.system-observability = { };
  services.prometheus = {
    enable = true;
    webExternalUrl = "https://internal.chlorodose.me/prometheus/";
    listenAddress = "127.0.0.1";
    port = 9099;
    retentionTime = "30d";
    exporters = {
      node = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9100;
        enabledCollectors = [
          "systemd"
          "softirqs"
          "qdisc"
          "processes"
          "perf"
          "mountstats"
          "cgroups"
          "ksmd"
          "interrupts"
          "ethtool"
        ];
        extraFlags = [
          "--collector.perf.cpus=0-71"
        ];
      };
      systemd = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9101;
        extraFlags = [
          "--systemd.collector.enable-restart-count"
          "--systemd.collector.enable-ip-accounting"
        ];
      };
      postgres = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9102;
        dataSourceName = "user=postgres-exporter database=postgres host=/run/postgresql sslmode=disable";
      };
      smartctl = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9103;
        maxInterval = "90s";
      };
      nginx = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9104;
        scrapeUri = "http://127.0.0.1/nginx_status";
      };
      v2ray = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9105;
        v2rayEndpoint = config.services.sing-box.settings.experimental.v2ray_api.listen;
      };
      wireguard = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9106;
        withRemoteIp = true;
      };
      nut = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9107;
        nutUser = "observer";
        passwordPath = "/etc/machine-id";
      };
      nvidia-gpu = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9108;
      };
      bitcoin = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9109;
        rpcPort = 8332;
        rpcUser = "observer";
        rpcPasswordFile = pkgs.writeText "rpc-password" "observer";
      };
    };
    scrapeConfigs = [
      {
        job_name = "prometheus";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.listenAddress}:${builtins.toString config.services.prometheus.port}"
            ];
          }
        ];
      }
      {
        job_name = "node";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.exporters.node.listenAddress}:${builtins.toString config.services.prometheus.exporters.node.port}"
            ];
          }
        ];
      }
      {
        job_name = "systemd";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.exporters.systemd.listenAddress}:${builtins.toString config.services.prometheus.exporters.systemd.port}"
            ];
          }
        ];
      }
      {
        job_name = "nvidia-gpu";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.exporters.nvidia-gpu.listenAddress}:${builtins.toString config.services.prometheus.exporters.nvidia-gpu.port}"
            ];
          }
        ];
      }
      {
        job_name = "smartctl";
        scrape_interval = "90s";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.exporters.smartctl.listenAddress}:${builtins.toString config.services.prometheus.exporters.smartctl.port}"
            ];
          }
        ];
      }
      {
        job_name = "nginx";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.exporters.nginx.listenAddress}:${builtins.toString config.services.prometheus.exporters.nginx.port}"
            ];
          }
        ];
      }
      {
        job_name = "postgres";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.exporters.postgres.listenAddress}:${builtins.toString config.services.prometheus.exporters.postgres.port}"
            ];
          }
        ];
      }
      {
        job_name = "nut-exporter";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.exporters.nut.listenAddress}:${builtins.toString config.services.prometheus.exporters.nut.port}"
            ];
          }
        ];
        relabel_configs = [
          {
            action = "replace";
            source_labels = [ "job" ];
            target_label = "job";
            regex = ".*";
            replacement = "nut";
          }
        ];
      }
      {
        job_name = "nut";
        scrape_interval = "2s";
        metrics_path = "/ups_metrics";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.exporters.nut.listenAddress}:${builtins.toString config.services.prometheus.exporters.nut.port}"
            ];
            labels = {
              ups = "ups";
            };
          }
        ];
      }
      {
        job_name = "sing-box";
        scrape_interval = "10s";
        metrics_path = "/scrape";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.exporters.v2ray.listenAddress}:${builtins.toString config.services.prometheus.exporters.v2ray.port}"
            ];
          }
        ];
      }
      {
        job_name = "bitcoin";
        scrape_interval = "10s";
        metrics_path = "/scrape";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.exporters.bitcoin.listenAddress}:${builtins.toString config.services.prometheus.exporters.bitcoin.port}"
            ];
          }
        ];
      }
      {
        job_name = "v2ray-exporter";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.exporters.v2ray.listenAddress}:${builtins.toString config.services.prometheus.exporters.v2ray.port}"
            ];
          }
        ];
        relabel_configs = [
          {
            action = "replace";
            source_labels = [ "job" ];
            target_label = "job";
            regex = ".*";
            replacement = "sing-box";
          }
        ];
      }
      {
        job_name = "wireguard";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.exporters.wireguard.listenAddress}:${builtins.toString config.services.prometheus.exporters.wireguard.port}"
            ];
          }
        ];
        metric_relabel_configs = lib.flatten (
          lib.mapAttrsToList (
            interface: value:
            (lib.map (peer: {
              action = "replace";
              source_labels = [
                "interface"
                "public_key"
              ];
              separator = ";-;";
              regex = "${lib.escapeRegex interface};-;${lib.escapeRegex peer.publicKey}";
              target_label = "friendly_name";
              replacement = peer.name;
            }) value.peers)
          ) config.networking.wireguard.interfaces
        );
      }
    ];
  };
  system.preserve.directories = ["/var/lib/${config.services.prometheus.stateDir}"];
  services.nginx.upstreams.prometheus = {
    servers = {
      "${config.services.prometheus.listenAddress}:${builtins.toString config.services.prometheus.port}" =
        { };
    };
  };
  systemd.services = lib.listToAttrs (
    lib.map
      (value: {
        name = value;
        value = {
          serviceConfig.Slice = config.systemd.slices.system-observability.name;
        };
      })
      [
        "prometheus"
        "prometheus-wireguard-exporter"
        "prometheus-nginx-exporter"
        "prometheus-node-exporter"
        "prometheus-nut-exporter"
        "prometheus-nvidia-gpu-exporter"
        "prometheus-postgres-exporter"
        "prometheus-smartctl-exporter"
        "prometheus-systemd-exporter"
        "prometheus-v2ray-exporter"
      ]
  );
}
