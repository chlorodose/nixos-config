{ config, lib, ... }:
{
  options.modules.remote.enable = lib.mkEnableOption "remote access";
  config = lib.mkIf config.modules.systemd-boot.enable {
    modules.machine.enable = true;
    services.openssh.settings.DenyUsers = null;
  };
}
