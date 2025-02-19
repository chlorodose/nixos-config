{ config, lib, ... }:
{
  options.modules.systemd-boot.enable = lib.mkEnableOption "systemd-boot";
  config = lib.mkIf config.modules.systemd-boot.enable {
    modules.machine.enable = true;
    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 32;
    };
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
