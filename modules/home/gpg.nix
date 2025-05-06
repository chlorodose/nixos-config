{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.user.gpg = {
    myKeys = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.path;
    };
  };
  options.modules.gpg-agent.enable = lib.mkEnableOption "gpg-agent";

  config = {
    services.gpg-agent = lib.mkIf config.modules.gpg-agent.enable {
      enable = true;
      enableExtraSocket = true;
      enableSshSupport = true;
      enableScDaemon = true;
      pinentry.package = pkgs.pinentry-all;
    };
    programs.gpg = {
      enable = true;
      publicKeys = lib.map (x: {
        source = x;
        trust = 5;
      }) config.user.gpg.myKeys;
    };
  };
}
