{ config, lib, ... }:
{
  options.modules.remote.enable = lib.mkEnableOption "systemd-boot";
  config = lib.mkIf config.modules.systemd-boot.enable {
    modules.machine.enable = true;
    services.openssh.settings.DenyUsers = null;
  };
}
