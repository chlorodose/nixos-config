{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.desktop.enable {
    services.kdeconnect.enable = true;
    systemd.user.services."kdeconnect".Unit.After = [ "graphical-session.target" ];
    services.kdeconnect.indicator = true;
    systemd.user.services."kdeconnect-indicator".Unit.After = [ "tray.target" ];
  };
}
