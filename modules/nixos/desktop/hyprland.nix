{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.modules.hyprland.enable = lib.mkEnableOption "hyprland";
  config = lib.mkIf config.modules.hyprland.enable {
    modules.desktop.enable = true;
    environment.systemPackages = with pkgs; [
      kitty
    ];
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
    programs.uwsm.enable = true;
    programs.hyprlock.enable = true;
  };
}
