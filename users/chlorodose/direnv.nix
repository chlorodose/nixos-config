{ config, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      whitelist.prefix = [
        "${config.xdg.userDirs.documents}"
      ];
    };
  };
}
