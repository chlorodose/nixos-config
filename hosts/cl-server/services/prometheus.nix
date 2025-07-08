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
    retentionTime = "90d";
    globalConfig = {
      scrape_timeout = "10s";
      scrape_interval = "10s";
    };
  };
  system.preserve.directories = [ "/var/lib/${config.services.prometheus.stateDir}" ];
  services.nginx.upstreams.prometheus = {
    servers = {
      "${config.services.prometheus.listenAddress}:${builtins.toString config.services.prometheus.port}" =
        { };
    };
  };
  systemd.services.prometheus.serviceConfig.Slice = config.systemd.slices.system-observability.name;
}
