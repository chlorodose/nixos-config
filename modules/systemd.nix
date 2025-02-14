{ ... }:
{
  systemd.watchdog.runtimeTime = "30s";
  systemd.extraConfig = "DefaultDeviceTimeoutSec = 3s";
}
