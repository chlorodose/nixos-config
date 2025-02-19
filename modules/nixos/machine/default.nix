{
  config,
  outputs,
  lib,
  pkgs,
  ...
}:
{
  imports = outputs.lib.scanPath ./.;
  options.modules.machine.enable = lib.mkEnableOption "machine";
  config = lib.mkIf config.modules.machine.enable {
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.initrd.systemd.enable = true;

    programs = {
      bash.enable = true;
      fish.enable = true;
      zsh.enable = true;
    };

    services.openssh.enable = true;
    services.openssh.settings.DenyUsers = lib.mkDefault [ "*" ];

    users.users.root.hashedPasswordFile = config.sops.secrets."user-passwords/root".path;
    sops.secrets."user-passwords/root" = {
      neededForUsers = true;
    };

    systemd.extraConfig = "DefaultDeviceTimeoutSec = 3s";
  };
}
