{ lib, ... }:
{
  imports = lib.scanPath ./.;
  time.timeZone = "Asia/Shanghai";
  networking.hostName = "cl-server";
  system.stateVersion = "25.05";

  modules.systemd-boot.enable = true;
}
