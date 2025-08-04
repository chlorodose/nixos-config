{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.desktop.enable {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "catppuccin"
        "catppuccin-blur"
        "catppuccin-icons"
        "rust-snippets"
        "nix"
        "make"
        "basher"
      ];
    };
  };
}
