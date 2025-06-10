{
  config,
  pkgs,
  outputs,
  ...
}:
{
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
}
