{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.desktop.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium.override {
        commandLineArgs = "--ozone-platform=wayland";
      };
    };
  };
}
