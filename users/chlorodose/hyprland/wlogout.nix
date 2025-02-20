{ lib, config, ... }:
{
  config = lib.mkIf config.modules.hyprland.enable {
    programs.wlogout.enable = true;
  };
}
