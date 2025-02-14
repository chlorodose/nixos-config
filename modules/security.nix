{ lib, ... }:
{
  users.mutableUsers = false;
  services.openssh.enable = true;
  services.openssh.settings.DenyUsers = lib.mkDefault [ "*" ];
}
