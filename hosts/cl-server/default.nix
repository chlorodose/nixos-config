{
  config,
  pkgs,
  outputs,
  ...
}:
{
  imports = [ outputs.nixosModule ] ++ (outputs.lib.scanPath ./.);
  time.timeZone = "Asia/Shanghai";
  networking.hostName = "cl-server";
  system.stateVersion = "25.05";

  modules.desktop.enable = false;
  modules.hyprland.enable = false;
  modules.regreet.enable = false;
  modules.machine.enable = true;
  modules.remote.enable = true;
  modules.systemd-boot.enable = true;
  modules.preservation.enable = true;

  users.users.chlorodose = {
    isNormalUser = true;
    uid = 1000;
    useDefaultShell = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
    ];
    hashedPasswordFile = config.sops.secrets."user-passwords/chlorodose".path;
  };
  sops.secrets."user-passwords/chlorodose" = {
    neededForUsers = true;
  };
}
