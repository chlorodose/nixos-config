{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.modules.desktop.enable {
    programs.element-desktop = {
      enable = true;
      settings = {
        default_server_config = {
          "m.homeserver" = {
            base_url = "https://matrix.chlorodose.me";
            server_name = "matrix.chlorodose.me";
          };
          "m.identity_server" = {
            base_url = "https://vector.im";
          };
        };
        room_directory.servers = [
          "matrix.org"
          "constellatory.net"
          "tchncs.de"
        ];
      };
    };
  };
}
