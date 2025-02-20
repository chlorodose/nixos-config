{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.hyprland.enable {
    services.swaync.enable = config.modules.hyprland.enable;
  };
}
