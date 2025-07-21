{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.modules.machine.enable {
    systemd.services.fsck-data = {
      description = "Run bcachefs fsck on data filesystem";
      requires = [ "mnt.mount" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.ExecStart = [
        "${lib.getExe pkgs.bcachefs-tools} fsck -p -y -k -v /dev/disk/by-label/data"
        "${lib.getExe pkgs.bcachefs-tools} data rereplicate /dev/disk/by-label/data"
      ];
    };
    systemd.timers.fsck-data = {
      description = "Run bcachefs fsck on data filesystem periodically";
      timerConfig = {
        OnBootSec = "30m";
        OnUnitActiveSec = "1d";
        RandomizedDelaySec = "1h";
      };
      wantedBy = [ "timers.target" ];
    };
    systemd.services.scrub-data = {
      description = "Scrub data filesystem";
      requires = [ "mnt.mount" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.ExecStart = "${lib.getExe pkgs.bcachefs-tools} data scrub /dev/disk/by-label/data";
    };
    systemd.timers.scrub-data = {
      description = "Run bcachefs scrub on data filesystem periodically";
      timerConfig = {
        OnBootSec = "2h";
        OnUnitActiveSec = "1w";
        RandomizedDelaySec = "1h";
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
