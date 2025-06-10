{
  config,
  outputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ../nix.nix ] ++ outputs.lib.scanPath ./.;
  config = {
    environment.systemPackages = with pkgs; [
      home-manager
      kitty.terminfo
    ];

    i18n = {
      defaultLocale = "C.UTF-8";
      supportedLocales = [
        "C.UTF-8/UTF-8"
        "zh_CN.UTF-8/UTF-8"
      ];
    };

    systemd.watchdog.runtimeTime = "30s";
    systemd.sleep.extraConfig = lib.mkDefault ''
      [Sleep]
      AllowSuspend=no
      AllowHibernation=no
      AllowHybridSleep=no
      AllowSuspendThenHibernate=no
    '';

    users.mutableUsers = false;
    security.sudo.extraConfig = lib.mkForce ''
      Defaults lecture = never
    '';

    networking.useNetworkd = true;
    networking.useDHCP = false;
    networking.nftables.enable = true;
    networking.firewall = {
      enable = true;
      checkReversePath = false;
      allowedUDPPorts = [
        5353
      ];
    };
    services.resolved = {
      enable = lib.mkDefault true;
      llmnr = "resolve";
      fallbackDns = [
        "1.1.1.1"
        "2606:4700:4700::1111"
        "223.5.5.5"
        "2400:3200::1"
      ];
    };

    nix = {
      channel.enable = false;
      daemonIOSchedClass = lib.mkDefault "best-effort";
      daemonCPUSchedPolicy = lib.mkDefault "other";
      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };
      settings.trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };
}
