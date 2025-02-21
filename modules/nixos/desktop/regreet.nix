{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.modules.regreet.enable = lib.mkEnableOption "regreet";
  config = lib.mkIf config.modules.regreet.enable {
    modules.desktop.enable = true;
    services.greetd.enable = true;
    programs.regreet = {
      enable = true;
      cageArgs = [
        "-s"
        "-m"
        "last"
      ];
      theme = {
        package = pkgs.catppuccin-gtk.override {
          accents = [ "mauve" ];
          variant = "mocha";
        };
        name = "catppuccin-mocha-mauve-standard";
      };
      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus";
      };
      cursorTheme = {
        package = pkgs.catppuccin-cursors;
        name = "mochaMauve";
      };
    };
  };
}
