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

    users."observer" = {
      upsmon = "secondary";
      passwordFile = "/dev/null";
    };
    users."exporter" = {
      upsmon = "secondary";
      passwordFile = builtins.toString (pkgs.writeText "no-password" "no-password");
    };

    upsmon.monitor.ups = {
      user = "observer";
      passwordFile = "/dev/null";
      system = "ups@127.0.0.1:3493";
    };

    upsmon.settings = {
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
    };
  };
  systemd.services.upsmon.after = [config.systemd.services.upsd.name];
}
