{ lib, config, ... }:
{
  config = lib.mkIf config.modules.desktop.enable {
    programs.kitty.enable = true;
    programs.kitty.themeFile = "Catppuccin-Mocha";
  };
}
