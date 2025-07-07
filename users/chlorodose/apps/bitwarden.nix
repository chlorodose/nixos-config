{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.modules.desktop.enable {
    programs.rbw = {
      enable = true;
      settings = {
        base_url = "https://vaultwarden.chlorodose.me";
        email = "chlorodose@chlorodose.me";
        pinentry = pkgs.pinentry-all;
      };
    };
    home.packages = [
      pkgs.bitwarden-desktop
    ];
  };
}
