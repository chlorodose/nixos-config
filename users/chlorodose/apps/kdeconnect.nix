{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.desktop.enable {
    services.kdeconnect.enable = true;
    services.kdeconnect.indicator = true;
  };
}
