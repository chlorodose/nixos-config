{ pkgs, config, ... }:
{
  qt = {
    enable = config.modules.desktop.enable;
    platformTheme = {
      name = "gtk";
      package = with pkgs; [
        libsForQt5.qtstyleplugins
        qt6Packages.qt6gtk2
      ];
    };
    style = {
      package = pkgs.lightly-qt;
      name = "Lightly";
    };
  };
  gtk = {
    enable = config.modules.desktop.enable;
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
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };
  };
}
