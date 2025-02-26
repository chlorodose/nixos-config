{
  lib,
  config,
  ...
}:
{
  options.modules.bluetooth.enable = lib.mkEnableOption "bluetooth";
  config = lib.mkIf config.modules.bluetooth.enable {
    services.blueman-applet.enable = true;
  };
}
