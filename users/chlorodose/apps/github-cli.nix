{ lib, config, ... }:
{
  config = lib.mkIf config.modules.desktop.enable {
    programs.gh.enable = true;
  };
}
