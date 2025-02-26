{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.desktop.enable {
    systemd.user.services."network-manager-applet".Unit.After = [ "graphical-session.target" ];
    services.network-manager-applet.enable = true;
  };
}
