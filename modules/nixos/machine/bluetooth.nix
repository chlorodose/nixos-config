{ config, lib, ... }:
{
  options.modules.bluetooth.enable = lib.mkEnableOption "bluetooth";
  config = lib.mkIf config.modules.bluetooth.enable {
    modules.machine.enable = true;
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}
