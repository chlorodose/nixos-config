{
  config,
  outputs,
  pkgs,
  lib,
  ...
}:
{
  boot.kernel.sysctl."kernel.perf_event_paranoid" = 0;
  services.prometheus.exporters = {
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
  services.ntpd-rs = {
    metrics.enable = true;
    settings.observability.metrics-exporter-listen = "127.0.0.1:9110";
  };
  services.matrix-synapse.settings.listeners = [
    {
      type = "metrics";
      tls = false;
      resources = [
        {
          names = [ "metrics" ];
        }
      ];
      port = 9111;
      bind_addresses = [ "127.0.0.1" ];
    }
  ];
  services.prometheus.scrapeConfigs = [
    {
      job_name = "prometheus";
      metrics_path = "prometheus/metrics";
      static_configs = [
        {
          targets = [
            "dashboard.chlorodose.me"
          ];
          labels.instance = config.networking.hostName;
        }
      ];
    }
    {
      job_name = "matrix-synapse";
      static_configs = [
        {
          targets = [
            "127.0.0.1:9111"
          ];
          labels.instance = config.networking.hostName;
        }
      ];
    }
    {
      job_name = "alertmanager";
      metrics_path = "alertmanager/metrics";
      static_configs = [
        {
          targets = [
            "dashboard.chlorodose.me"
          ];
          labels.instance = config.networking.hostName;
        }
      ];
    }
    {
      job_name = "grafana";
      static_configs = [
        {
          targets = [
            "dashboard.chlorodose.me"
          ];
          labels.instance = config.networking.hostName;
        }
      ];
    }
    {
      job_name = "node";
      static_configs = [
        {
          targets = [
            "${config.services.prometheus.exporters.node.listenAddress}:${builtins.toString config.services.prometheus.exporters.node.port}"
          ];
          labels.instance = config.networking.hostName;
        }
      ];
    }
    {
      job_name = "systemd";
      static_configs = [
        {
          targets = [
            "${config.services.prometheus.exporters.systemd.listenAddress}:${builtins.toString config.services.prometheus.exporters.systemd.port}"
          ];
          labels.instance = config.networking.hostName;
        }
      ];
    }
    {
      job_name = "nvidia-gpu";
      static_configs = [
        {
          targets = [
            "${config.services.prometheus.exporters.nvidia-gpu.listenAddress}:${builtins.toString config.services.prometheus.exporters.nvidia-gpu.port}"
          ];
          labels.instance = config.networking.hostName;
        }
      ];
    }
    {
      job_name = "smartctl";
      scrape_interval = "90s";
      scrape_timeout = "30s";
      static_configs = [
        {
          targets = [
            "${config.services.prometheus.exporters.smartctl.listenAddress}:${builtins.toString config.services.prometheus.exporters.smartctl.port}"
          ];
          labels.instance = config.networking.hostName;
        }
      ];
    }
    {
      job_name = "nginx";
      static_configs = [
        {
          targets = [
            "${config.services.prometheus.exporters.nginx.listenAddress}:${builtins.toString config.services.prometheus.exporters.nginx.port}"
          ];
          labels.instance = config.networking.hostName;
        }
      ];
    }
    {
      job_name = "postgres";
      static_configs = [
        {
          targets = [
            "${config.services.prometheus.exporters.postgres.listenAddress}:${builtins.toString config.services.prometheus.exporters.postgres.port}"
          ];
          labels.instance = config.networking.hostName;
        }
      ];
    }
    {
      job_name = "nut-exporter";
      static_configs = [
        {
          targets = [
            "${config.services.prometheus.exporters.nut.listenAddress}:${builtins.toString config.services.prometheus.exporters.nut.port}"
          ];
          labels.instance = config.networking.hostName;
        }
      ];
    }
    {
      job_name = "nut";
      scrape_interval = "5s";
      scrape_timeout = "5s";
      metrics_path = "/ups_metrics";
      params.ups = [ "ups" ];
      static_configs = [
        {
          targets = [
            "${config.services.prometheus.exporters.nut.listenAddress}:${builtins.toString config.services.prometheus.exporters.nut.port}"
          ];
          labels = {
            ups = "ups";
            instance = config.networking.hostName;
          };
        }
      ];
    }
    {
      job_name = "sing-box";
      metrics_path = "/scrape";
      static_configs = [
        {
          targets = [
            "${config.services.prometheus.exporters.v2ray.listenAddress}:${builtins.toString config.services.prometheus.exporters.v2ray.port}"
          ];
          labels.instance = config.networking.hostName;
        }
      ];
    }
    {
      job_name = "bitcoin";
      scrape_interval = "30s";
      scrape_timeout = "30s";
      metrics_path = "/scrape";
      static_configs = [
        {
          targets = [
            "${config.services.prometheus.exporters.bitcoin.listenAddress}:${builtins.toString config.services.prometheus.exporters.bitcoin.port}"
          ];
          labels.instance = config.networking.hostName;
        }
      ];
    }
    {
      job_name = "sing-box-exporter";
      static_configs = [
        {
          targets = [
            "${config.services.prometheus.exporters.v2ray.listenAddress}:${builtins.toString config.services.prometheus.exporters.v2ray.port}"
          ];
          labels.instance = config.networking.hostName;
        }
      ];
    }
    {
      job_name = "ntpd";
      static_configs = [
        {
          targets = [
            config.services.ntpd-rs.settings.observability.metrics-exporter-listen
          ];
          labels.instance = config.networking.hostName;
        }
      ];
    }
    {
      job_name = "wireguard";
      static_configs = [
        {
          targets = [
            "${config.services.prometheus.exporters.wireguard.listenAddress}:${builtins.toString config.services.prometheus.exporters.wireguard.port}"
          ];
          labels.instance = config.networking.hostName;
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
  systemd.services = lib.listToAttrs (
    lib.map
      (value: {
        name = value;
        value = {
          serviceConfig.Slice = config.systemd.slices.system-observability.name;
        };
      })
      [
        "prometheus-wireguard-exporter"
        "prometheus-nginx-exporter"
        "prometheus-node-exporter"
        "prometheus-nut-exporter"
        "prometheus-nvidia-gpu-exporter"
        "prometheus-postgres-exporter"
        "prometheus-smartctl-exporter"
        "prometheus-systemd-exporter"
        "prometheus-v2ray-exporter"
        "ntpd-rs-metrics"
      ]
  );
}
