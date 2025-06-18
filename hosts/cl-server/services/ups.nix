{
  config,
  lib,
  pkgs,
  ...
}:
{
  power.ups = {
    enable = true;
    mode = "standalone";
    maxStartDelay = 30;

    upsd = {
      enable = true;
      listen = [
        {
          address = "127.0.0.1";
          port = 3493;
        }
      ];
    };

    ups."ups" = {
      description = "Main UPS";
      driver = "nutdrv_qx";
      port = "auto";
      summary = ''
        vendorid = "0665"
        productid = "5161"
      '';
    };

    users."root" = {
      upsmon = "primary";
      passwordFile = "/etc/machine-id";
      instcmds = [ "ALL" ];
      actions = [
        "SET"
        "FSD"
      ];
    };
    users."exporter" = {
      upsmon = "secondary";
      passwordFile = "/etc/machine-id";
    };

    upsmon.monitor.ups = {
      user = "root";
      passwordFile = "/etc/machine-id";
      system = "ups@127.0.0.1:3493";
    };

    upsmon = {
      user = "root";
      group = "root";
      settings = {
        DEADTIME = 5;
        NOCOMMWARNTIME = 30;
        NOTIFYFLAG = [
          [
            "ONLINE"
            "SYSLOG"
          ]
          [
            "ONBATT"
            "SYSLOG+WALL"
          ]
          [
            "LOWBATT"
            "SYSLOG+WALL"
          ]
        ];
        POLLFREQ = 2;
        POLLFREQALERT = 1;
        SHUTDOWNCMD = "${pkgs.systemd}/bin/systemctl poweroff";
        RUN_AS_USER = "root";
      };
    };
  };
  systemd.services.upsd = {
    serviceConfig.NotifyAccess = "all";
    after = lib.mkForce [ ];
  };
  systemd.services.upsmon = {
    serviceConfig.NotifyAccess = "all";
    after = lib.mkForce [ config.systemd.services.upsd.name ];
  };
}
