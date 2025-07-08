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
  boot.kernel.sysctl."kernel.perf_event_paranoid" = 0;
  systemd.slices.system-observability.sliceConfig = {
    CPUWeight = 50;
    MemoryHigh = "32G";
    IOWeight = 60;
  };
  services.prometheus = {
    enable = true;
    webExternalUrl = "https://dashboard.chlorodose.me/prometheus/";
    listenAddress = "127.0.0.1";
    port = 9099;
    retentionTime = "30d";
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
        passwordPath = config.sops.secrets."random-pass".path;
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
        metrics_path = "prometheus/metrics";
        static_configs = [
          {
            targets = [
              "dashboard.chlorodose.me"
            ];
          }
        ];
      }
      {
        job_name = "alertmanager";
        scrape_interval = "10s";
        metrics_path = "alertmanager/metrics";
        static_configs = [
          {
            targets = [
              "dashboard.chlorodose.me"
            ];
          }
        ];
      }
      {
        job_name = "grafana";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [
              "dashboard.chlorodose.me"
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
  system.preserve.directories = [ "/var/lib/${config.services.prometheus.stateDir}" ];
  services.nginx.upstreams.prometheus = {
    servers = {
      "${config.services.prometheus.listenAddress}:${builtins.toString config.services.prometheus.port}" =
        { };
    };
  };
  services.nginx.upstreams.alertmanager = {
    servers = {
      "${config.services.prometheus.alertmanager.listenAddress}:${builtins.toString config.services.prometheus.alertmanager.port}" =
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
        "alertmanager"
        "matrix-alertmanager"
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
