{
  pkgs,
  config,
  outputs,
  ...
}:
{
  sops.secrets."vaultwarden" = {
    sopsFile = outputs.lib.getSecret "services.yaml";
    mode = "0400";
    owner = "root";
    group = "vaultwarden";
  };
  systemd.slices.system-vaultwarden.sliceConfig = {
    CPUWeight = 400;
    IOWeight = 600;
  };
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    environmentFile = config.sops.secrets."vaultwarden".path;
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      DATA_FOLDER = "/var/lib/vaultwarden";
      DATABASE_URL = "postgresql://vaultwarden@/vaultwarden";
      ENABLE_DB_WAL = true;
      DATABASE_MAX_CONNS = 128;
      ENABLE_WEBSOCKET = true;
      DOMAIN = "https://vaultwarden.chlorodose.me";
      SENDS_ALLOWED = true;
      # HIBP_API_KEY = "";
      ORG_ATTACHMENT_LIMIT = 64 * 1024 * 1024;
      USER_ATTACHMENT_LIMIT = 64 * 1024 * 1024;
      USER_SEND_LIMIT = 64 * 1024 * 1024;
      DISABLE_ICON_DOWNLOAD = false;
      INCOMPLETE_2FA_TIME_LIMIT = 3;
      SIGNUPS_ALLOWED = false;
      SIGNUPS_VERIFY = false;
      ICON_SERVICE = "internal";
      IP_HEADER = "X-Real-IP";
      HTTP_REQUEST_BLOCK_NON_GLOBAL_IPS = false;
      USE_SYSLOG = true;
      LOG_LEVEL = "info";
      ORG_EVENTS_ENABLED = true;
      ORG_CREATION_USERS = "none";
      INVITATION_EXPIRATION_HOURS = 72;
      EMERGENCY_ACCESS_ALLOWED = false;
      EMAIL_CHANGE_ALLOWED = false;
      INVITATIONS_ALLOWED = false;
      PASSWORD_HINTS_ALLOWED = true;
      REQUIRE_DEVICE_EMAIL = false;
      PUSH_ENABLED = true;
      EXPERIMENTAL_CLIENT_FEATURE_FLAGS = "inline-menu-positioning-improvements,inline-menu-totp,export-attachments";
      PUSH_RELAY_URI = "https://push.bitwarden.com";
      PUSH_IDENTITY_URI = "https://identity.bitwarden.com";
      HTTP_PROXY = "http://127.0.0.1:7890";
      HTTPS_PROXY = "http://127.0.0.1:7890";
    };
  };
  systemd.services.vaultwarden.requires = [ "postgresql.service" ];
  system.preserve.directories = [ config.services.vaultwarden.config.DATA_FOLDER ];
  systemd.services.vaultwarden.serviceConfig.Slice = config.systemd.slices.system-vaultwarden.name;
  services.nginx.upstreams.vaultwarden = {
    servers = {
      "${config.services.vaultwarden.config.ROCKET_ADDRESS}:${builtins.toString config.services.vaultwarden.config.ROCKET_PORT}" =
        { };
    };
  };
}
