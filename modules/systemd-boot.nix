{ lib, ... }:
{
  options.modules.systemd-boot.enable = lib.mkEnableOption "systemd-boot";
  config = {
    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 32;
    };
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
