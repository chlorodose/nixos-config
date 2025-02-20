{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.modules.gpg-agent.enable = lib.mkEnableOption "gpg-agent";

  config = lib.mkIf config.modules.gpg-agent.enable {
    services.gpg-agent = {
      enable = true;
      enableExtraSocket = true;
      enableSshSupport = true;
      enableScDaemon = true;
      pinentryPackage = pkgs.pinentry-all;
    };
  };
}
