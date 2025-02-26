{
  config,
  outputs,
  pkgs,
  ...
}:
{
  imports = [ outputs.nixosModules.default ] ++ (outputs.lib.scanPath ./.);
  time.timeZone = "Asia/Shanghai";
  networking.hostName = "cl-laptop";
  system.stateVersion = "25.05";

  modules.desktop.enable = true;
  modules.hyprland.enable = true;
  modules.regreet.enable = true;
  modules.machine.enable = true;
  modules.remote.enable = false;
  modules.systemd-boot.enable = true;
  modules.preservation.enable = true;
  modules.bluetooth.enable = true;
  modules.kdeconnect.enable = true;

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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKF7rjnMuwq0bB/G4dXVSZHegO06qKm4BSBREUHml7Dp chlorodose <chlorodose@chlorodose.me>"
    ];
  };
  sops.secrets."user-passwords/chlorodose" = {
    neededForUsers = true;
  };
}
