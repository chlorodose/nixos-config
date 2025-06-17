{
  config,
  pkgs,
  outputs,
  lib,
  ...
}:
{
  systemd.slices.system-fileshare = { };
  systemd.slices.system-fileshare-samba = { };

  users.users.chlorodose = { };
  users.users."250991817" = {
    isNormalUser = true;
    useDefaultShell = true;
    createHome = false;
    home = "/var/empty";
  };
  sops.secrets."samba-password" = {
    format = "binary";
    sopsFile = outputs.lib.getSecret "samba/smbpasswd";
    mode = "0400";
    owner = "root";
  };
  services.samba = {
    enable = true;
    settings = {
      global = {
        "passwd program" = "";
        "passdb backend" = "smbpasswd:${config.sops.secrets."samba-password".path}";
      };
      homes = {
        path = "/srv/share/%S";
        browseable = true;
        "read only" = false;
      };
    };
  };
  systemd.services = lib.listToAttrs (
    lib.map
      (value: {
        name = value;
        value = {
          serviceConfig.Slice = lib.mkForce config.systemd.slices.system-fileshare-samba.name;
        };
      })
      [
        "samba-nmb"
        "samba-smbd"
        "samba-winbindd"
      ]
  );
}
