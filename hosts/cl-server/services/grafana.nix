{ config, outputs, ... }:
{
  sops.secrets."grafana/password" = {
    sopsFile = outputs.lib.getSecret "services.yaml";
    mode = "400";
    owner = "grafana";
  };
  services.grafana = {
    enable = true;
    settings =
      let
        quoteFile = file: "$__file{${file}}";
      in
      {
        server = {
          http_addr = "0.0.0.0";
          http_port = 8080;
        };
        security = {
          admin_user = "admin";
          admin_password = quoteFile config.sops.secrets."grafana/password".path;
          secret_key = quoteFile config.sops.secrets."grafana/password".path;
        };
      };
    provision = {
      enable = true;
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Default";
            type = "prometheus";
            isDefault = true;
            uid = "default";
            url = "http://${
              if config.services.prometheus.listenAddress != "0.0.0.0" then
                config.services.prometheus.listenAddress
              else
                "127.0.0.1"
            }:${toString config.services.prometheus.port}";
            jsonData = {
              timeInterval = "1s";
              cacheLevel = "High";
              incrementalQuerying = "true";
            };
            editable = false;
          }
        ];
      };
    };
  };
}
