{ lib, ... }:
{
  imports = lib.scanPath ./.;
  time.timeZone = "Asia/Shanghai";
  networking.hostName = "cl-laptop";
  system.stateVersion = "25.05";

  modules.systemd-boot.enable = true;
}
