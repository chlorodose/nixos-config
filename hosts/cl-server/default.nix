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

  services.openssh.settings.PasswordAuthentication = false;

  users.users.chlorodose = {
    isNormalUser = true;
    uid = 1000;
    useDefaultShell = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
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
