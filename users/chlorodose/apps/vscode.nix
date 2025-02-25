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
      package = pkgs.vscode.override {
        commandLineArgs = "--ozone-platform-hint=auto --enable-wayland-ime";
      };
    };
  };
}
