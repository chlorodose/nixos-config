{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.hyprland.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
    };
  };
}
