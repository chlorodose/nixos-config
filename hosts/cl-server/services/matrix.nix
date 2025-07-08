{
  config,
  lib,
  outputs,
  ...
}:
{
  systemd.slices.system-chat.sliceConfig = {
    CPUWeight = 100;
    IOWeight = 100;
  };
  services.matrix-continuwuity = {
    enable = true;
    settings = {
      global = {
        address = null;
        unix_socket_path = "/run/continuwuity/matrix.sock";
        trusted_servers = [
          "matrix.org"
          "constellatory.net"
          "tchncs.de"
        ];
        server_name = "matrix.chlorodose.me";
        new_user_displayname_suffix = "";
        max_request_size = 16 * 1024 * 1024 * 1024;
        allow_public_room_directory_over_federation = true;
        allow_public_room_directory_without_auth = true;
        allow_registration = false;
        yes_i_am_very_very_sure_i_want_an_open_registration_server_prone_to_abuse = false;
        proxy.global.url = "socks5h://127.0.0.1:7890";
        rocksdb_log_stderr = true;
        rocksdb_stats_level = 2;
        rocksdb_direct_io = false;
        zstd_compression = true;
        well_known = {
          client = "https://matrix.chlorodose.me";
          server = "matrix.chlorodose.me:443";
          support_email = "chlorodose@chlorodose.me";
          support_role = "m.role.admin";
          support_mxid = "@chlorodose:matrix.chlorodose.me";
          support_page = "https://matrix.chlorodose.me/support";
        };
      };
    };
  };
  users.users.nginx.extraGroups = [ config.services.matrix-continuwuity.group ];
  systemd.services.continuwuity.serviceConfig = {
    DynamicUser = lib.mkForce false;
    Slice = config.systemd.slices.system-chat.name;
  };
  system.preserve.directories = [ config.services.matrix-continuwuity.settings.global.database_path ];
  services.nginx.upstreams.continuwuity = {
    servers = {
      "unix:${config.services.matrix-continuwuity.settings.global.unix_socket_path}" = { };
    };
  };
}
