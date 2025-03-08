{ lib, ... }:
{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    enableJIT = true;
    dataDir = "/srv/postgresql";
    authentication = lib.mkForce ''
      local all all   peer
    '';
  };
}
