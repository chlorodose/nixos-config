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
              annotations.summary = "Prometheus抓取失败 (instance={{ $labels.instance }}, job={{ $labels.job }})";
            }
            {
              alert = "Prometheus Alertmanager Disconnected";
              expr = "prometheus_notifications_alertmanagers_discovered < 1";
              for = "0s";
              labels.severity = "critical";
              annotations.summary = "Prometheus无法连接到至少一个Alertmanager (instance={{ $labels.instance }})";
            }
            {
              alert = "Prometheus Rule Evaluation Failed";
              expr = "increase(prometheus_rule_evaluation_failures_total[30s]) > 0";
              for = "0s";
              keep_firing_for = "3m";
              labels.severity = "critical";
              annotations.summary = "Prometheus规则评估失败 (instance={{ $labels.instance }})";
            }
            {
              alert = "Prometheus Template Expansion Failed";
              expr = "increase(prometheus_template_text_expansion_failures_total[30s]) > 0";
              for = "0s";
              keep_firing_for = "3m";
              labels.severity = "critical";
              annotations.summary = "Prometheus模板文本展开失败 (instance={{ $labels.instance }})";
            }
            {
              alert = "Postgresql Down";
              expr = "pg_up == 0";
              for = "0s";
              keep_firing_for = "3m";
              labels.severity = "critical";
              annotations.summary = "Postgresql宕机 (instance={{ $labels.instance }})";
            }
          ];
        }
        {
          name = "Performance";
          interval = "90s";
          rules = makeRuleList [
            {
              alert = "Prometheus Rule Slow Evaluation";
              expr = "prometheus_rule_group_last_duration_seconds > prometheus_rule_group_interval_seconds";
              for = "30s";
              keep_firing_for = "10m";
              labels.severity = "warning";
              annotations.summary = "Prometheus规则评估的花费时间超过了间隔时间 (instance={{ $labels.instance }})";
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
