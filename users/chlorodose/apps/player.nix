{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.modules.desktop.enable {
    home.packages = [
      pkgs.vlc
    ];
  };
}
