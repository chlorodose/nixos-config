{ outputs, ... }:
{
  imports = [ outputs.nixosModule ] ++ (outputs.lib.scanPath ./.);
  time.timeZone = "Asia/Shanghai";
  networking.hostName = "cl-laptop";
  system.stateVersion = "25.05";

  modules.desktop.enable = true;
  modules.hyprland.enable = true;
  modules.regreet.enable = true;
  modules.systemd-boot.enable = true;
  modules.preservation.enable = true;
}
