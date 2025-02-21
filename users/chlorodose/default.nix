{ config, outputs, ... }:
{
  imports = [ outputs.homeModules.default ] ++ outputs.lib.scanPath ./.;
  config = {
    home.username = "chlorodose";
    home.homeDirectory = "/home/${config.home.username}";
    home.stateVersion = "25.05";
  };
}
