{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    modules.bcachefs.enable = lib.mkEnableOption "bcachefs";
    modules.zfs.enable = lib.mkEnableOption "zfs";
  };
  config = lib.mkIf config.modules.machine.enable {
    warnings = lib.optional (config.modules.bcachefs.enable && config.modules.zfs.enable) [
      "Do not enable zfs and bcachefs at same time"
    ];
    services.zfs.autoScrub = lib.mkIf config.modules.zfs.enable {
      enable = true;
      interval = "weekly";
      pools = [ "datapool" ];
    };
    systemd.services.fsck-bcachefs = lib.mkIf config.modules.bcachefs.enable {
      description = "Run bcachefs fsck on data filesystem";
      requires = [ "mnt.mount" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.ExecStart = [
        "${lib.getExe pkgs.bcachefs-tools} fsck -p -y -k -v /dev/disk/by-label/data"
        "${lib.getExe pkgs.bcachefs-tools} data rereplicate /dev/disk/by-label/data"
      ];
    };
    systemd.timers.fsck-bcachefs = lib.mkIf config.modules.bcachefs.enable {
      description = "Run bcachefs fsck on data filesystem periodically";
      timerConfig = {
        OnBootSec = "30m";
        OnUnitActiveSec = "1d";
        RandomizedDelaySec = "1h";
      };
      wantedBy = [ "timers.target" ];
    };
    systemd.services.scrub-bcachefs = lib.mkIf config.modules.bcachefs.enable {
      description = "Scrub bcache filesystem";
      requires = [ "mnt.mount" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.ExecStart = "${lib.getExe pkgs.bcachefs-tools} data scrub /dev/disk/by-label/data";
    };
    systemd.timers.scrub-bcachefs = lib.mkIf config.modules.bcachefs.enable {
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
