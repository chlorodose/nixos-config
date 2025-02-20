{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.services.ups.enable = lib.mkEnableOption "ups service";

  config = lib.mkIf config.services.ups.enable {
    power.ups = {
      enable = true;
      mode = "standalone";
      ups."ups" = {
        driver = "nutdrv_qx";
        description = "ups";
        port = "auto";
        summary = ''
          vendorid = "0665"
          productid = "5161"
        '';
      };

      users."ups" = {
        upsmon = "primary";
        instcmds = [ "ALL" ];
        actions = [ "SET" ];
        passwordFile = "/dev/null";
      };

      upsmon.monitor.ups = {
        user = "ups";
        passwordFile = "/dev/null";
        system = "ups@localhost";
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
            "SYSLOG+WALL+EXEC"
          ]
          [
            "LOWBATT"
            "SYSLOG+WALL+EXEC"
          ]
        ];
        POLLFREQ = 2;
        POLLFREQALERT = 1;
        RUN_AS_USER = "root";
        SHUTDOWNCMD = "${pkgs.systemd}/bin/systemctl poweroff";
      };
    };
  };
}
