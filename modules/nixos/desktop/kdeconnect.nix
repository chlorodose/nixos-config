{
  lib,
  config,
  ...
}:
{
  options.modules.kdeconnect.enable = lib.mkEnableOption "kdeconnect";
  config = lib.mkIf config.modules.kdeconnect.enable {
    modules.desktop.enable = true;
    networking.firewall = {
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
  };
}
