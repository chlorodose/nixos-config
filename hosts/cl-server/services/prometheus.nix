{ config, ... }:
{
  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.99";
    port = 9900;
    retentionTime = "4w";
  };
  system.preserve.directories = [ "/var/lib/${config.services.prometheus.stateDir}" ];
}
