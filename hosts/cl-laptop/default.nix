{
  config,
  outputs,
  pkgs,
  ...
}:
{
  imports = [ outputs.nixosModule ] ++ (outputs.lib.scanPath ./.);
  time.timeZone = "Asia/Shanghai";
  networking.hostName = "cl-laptop";
  system.stateVersion = "25.05";

  modules.desktop.enable = true;
  modules.hyprland.enable = true;
  modules.regreet.enable = false;
  modules.systemd-boot.enable = true;
  modules.preservation.enable = true;

  users.users.chlorodose = {
    isNormalUser = true;
    uid = 1000;
    useDefaultShell = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    hashedPasswordFile = config.sops.secrets."user-passwords/chlorodose".path;
  };
  sops.secrets."user-passwords/chlorodose" = {
    neededForUsers = true;
  };
}
