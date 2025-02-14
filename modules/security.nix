{ config, lib, ... }:
{
  users.mutableUsers = false;
  services.openssh.enable = true;
  services.openssh.settings.DenyUsers = lib.mkDefault [ "*" ];

  users.users.root.hashedPasswordFile = config.sops.secrets."user-passwords/root".path;
  sops.secrets."user-passwords/root" = {
    neededForUsers = true;
  };
}
