{ config, outputs, ... }:
{
  imports = [ outputs.homeModule ] ++ outputs.lib.scanPath ./.;
  config = {
    home.username = "chlorodose";
    home.homeDirectory = "/home/${config.home.username}";
    home.stateVersion = "25.05";
  };
}
