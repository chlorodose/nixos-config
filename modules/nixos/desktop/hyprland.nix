{ config, lib, ... }:
{
  options.modules.hyprland.enable = lib.mkEnableOption "hyprland";
  config = lib.mkIf config.modules.hyprland.enable {
    modules.desktop.enable = true;
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
    programs.uwsm.enable = true;
    programs.hyprlock.enable = true;
  };
}
