{
  config,
  lib,
  outputs,
  ...
}:
{
  imports = outputs.lib.scanPath ./.;
  options.modules.hyprland.enable = lib.mkEnableOption "hyprland";
  config.modules.desktop.enable = lib.mkIf config.modules.hyprland.enable true;
}
