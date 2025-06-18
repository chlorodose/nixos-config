{ config, pkgs, ... }:
{
  services.grafana = {
    enable = true;
    settings.server = {
      protocol = "http";
      http_addr = "127.0.0.1";
      http_port = 3123;
      serve_from_sub_path = true;
      root_url = "https://internal.chlorodose.me/grafana";
    };
    settings."auth.anonymous" = {
      enabled = true;
      org_name = "Main Org.";
      org_role = "Viewer";
    };
    settings.database = {
      type = "postgres";
      name = "grafana";
      user = "grafana";
      host = "/run/postgresql";
    };
    settings.security = {
      cookie_secure = true;
      allow_embedding = true;
    };
    settings.users = {
      viewers_can_edit = true;
      default_theme = "system";
      default_language = "zh-Hans";
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "prometheus";
          type = "prometheus";
          uid = "prometheus";
          url = "http://${config.services.prometheus.listenAddress}:${builtins.toString config.services.prometheus.port}/prometheus";
          jsonData = {
            manageAlerts = true;
            cacheLevel = "Low";
          };
        }
      ];
      dashboards.settings.providers = [
        {
          name = "default";
          orgId = 1;
          type = "file";
          disableDeletion = false;
          allowUiUpdates = true;
          updateIntervalSeconds = 15;
          options = {
            path = "/srv/grafana";
            foldersFromFilesStructure = true;
          };
        }
      ];
    };
  };
  services.nginx.upstreams.grafana = {
    servers = {
      "${config.services.grafana.settings.server.http_addr}:${builtins.toString config.services.grafana.settings.server.http_port}" =
        { };
    };
  };
  systemd.services.grafana.serviceConfig.Slice = config.systemd.slices.system-web.name;
}
