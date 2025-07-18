{
  config,
  pkgs,
  outputs,
  ...
}:
{
  imports = [ outputs.nixosModules.default ] ++ (outputs.lib.scanPath ./.);
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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKF7rjnMuwq0bB/G4dXVSZHegO06qKm4BSBREUHml7Dp chlorodose <chlorodose@chlorodose.me>"
    ];
  };
  nix.sshServe = {
    enable = true;
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBRpuuX5ge+p2FTsozYFJURT0PLV+hFURV2SkBfKLa56 nix-ssh@cl-server"
    ];
    trusted = true;
    write = true;
  };
  sops.secrets."user-passwords/chlorodose" = {
    neededForUsers = true;
  };

  
}
