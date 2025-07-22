{
  pkgs,
  config,
  lib,
  outputs,
  ...
}:
{
  sops.secrets."google-assistant" = {
    format = "binary";
    sopsFile = outputs.lib.getSecret "hass/google-assistant.json";
    mode = "0440";
    owner = "root";
    group = "hass";
  };
  systemd.slices.system-hass.sliceConfig = {
    CPUWeight = 100;
    MemoryHigh = "32G";
    IOWeight = 100;
  };
  services.home-assistant = {
    enable = true;
    configDir = "/var/lib/hass";
    config = {
      config = { };
      history = { };
      map = { };
      mobile_app = { };
      sun = { };
      system_health = { };
      google_assistant = {
        project_id = "homelab-home-assistant";
        service_account = "!include ${config.sops.secrets."google-assistant".path}";
        report_state = true;
        exposed_domains = [
          "select"
          "switch"
          "climate"
        ];
      };

      automation = "!include automations.yaml";
      http = {
        server_host = [
          "127.0.0.1"
          "::1"
        ];
        server_port = 8123;
        ip_ban_enabled = false;
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
      };
      homeassistant = {
        name = "Home";
        temperature_unit = "C";
        time_zone = config.time.timeZone;
        unit_system = "metric";
        currency = "CNY";
        country = "CN";
        external_url = "https://hass.chlorodose.me";
        internal_url = "https://ihass.chlorodose.me";
        longitude = "!secret longitude";
        latitude = "!secret latitude";
        elevation = "!secret elevation";
        radius = "10";
      };
    };
    extraComponents = [
      "default_config"
      "met"
      "esphome"
      "ffmpeg"
      "homekit"
      "nut"
      "google_assistant"
    ];
    customComponents = [
      (pkgs.home-assistant-custom-components.xiaomi_miot.overrideAttrs (
        finalAttrs: previousAttrs: {
          src = pkgs.fetchFromGitHub {
            owner = "al-one";
            repo = "hass-xiaomi-miot";
            rev = "aa99f3885405ede068dd117b5b2657184586ddcb";
            hash = "sha256-kifImeiytb7t+eyRCmHKPR+IkXkpsRKg0yikIQLX+40=";
          };
        }
      ))
    ];
  };
  system.preserve.directories = [ "/var/lib/hass" ];
  services.nginx.upstreams.home-assistant = {
    servers = {
      "127.0.0.1:${builtins.toString config.services.home-assistant.config.http.server_port}" = { };
    };
  };
  systemd.services.home-assistant.serviceConfig.Slice = config.systemd.slices.system-hass.name;
}
