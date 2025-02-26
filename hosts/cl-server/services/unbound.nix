{ lib, ... }:
{
  services.resolved.enable = lib.mkForce false;
  services.unbound = {
    enable = true;
    localControlSocketPath = "/run/unbound/unbound.ctl";
    settings = {
      server = {
        statistics-interval = 10;
        extended-statistics = true;
        interface = [
          "0.0.0.0"
          "::0"
        ];
        access-control = [
          "0.0.0.0/0 allow_snoop"
          "::/0 allow_snoop"
        ];
        log-queries = true;
        prefetch = true;
        prefetch-key = true;
        local-zone = ''"local." static'';
        local-data = [
          ''"nextcloud.local. 600 IN A 192.168.0.1"''
          ''"grafana.local. 600 IN A 192.168.0.1"''
        ];
      };
      forward-zone = [
        {
          name = ".";
          forward-addr = "1.1.1.1@853#1.1.1.1";
          forward-first = true;
        }
      ];
    };
  };
}
