{ lib, ... }:
{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    enableJIT = true;
    dataDir = "/srv/postgresql";
    authentication = lib.mkForce ''
      local all all   peer
      host  all admin 192.168.0.0/24  password
      host  all admin 192.168.1.0/24  password
    '';
    ensureUsers = [
      {
        name = "root";
        ensureClauses.superuser = true;
        ensureClauses.login = true;
      }
    ];
  };
}
