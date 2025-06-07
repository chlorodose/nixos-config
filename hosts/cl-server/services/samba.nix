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
  sops.secrets."samba" = {
    sopsFile = outputs.lib.getSecret "services.yaml";
    mode = "0400";
    owner = "root";
  };
  systemd.services."samba-smbd" = {
    preStart = ''
      ${pkgs.coreutils}/bin/mkdir -p /var/lib/samba/private &&
      ${pkgs.samba}/bin/pdbedit -i smbpasswd:${
        config.sops.secrets."samba".path
      } -e tdbsam:/var/lib/samba/private/passdb.tdb
    '';
  };
  services.samba = {
    enable = true;
    settings = {
      global = {
        "passwd program" = "";
      };
      homes = {
        path = "/srv/share/%S";
        browseable = true;
        "read only" = false;
      };
    };
  };
}
