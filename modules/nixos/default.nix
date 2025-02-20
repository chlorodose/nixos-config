{
  outputs,
  pkgs,
  lib,
  ...
}:
{
  imports = outputs.lib.scanPath ./.;
  config = {
    environment.systemPackages = with pkgs; [
      home-manager
    ];

    i18n = {
      defaultLocale = "C.UTF-8";
      supportedLocales = [
        "C.UTF-8/UTF-8"
        "zh_CN.UTF-8/UTF-8"
      ];
    };

    systemd.watchdog.runtimeTime = "30s";

    users.mutableUsers = false;
    security.sudo.extraConfig = lib.mkForce ''
      Defaults lecture = never
    '';

    networking.useNetworkd = true;
    networking.useDHCP = false;
    networking.nftables.enable = true;
    networking.firewall.enable = true;
    services.resolved = {
      enable = lib.mkDefault true;
      fallbackDns = [
        "1.1.1.1"
        "2606:4700:4700::1111"
        "223.5.5.5"
        "2400:3200::1"
      ];
    };

    nix = {
      package = pkgs.lix;
      channel.enable = false;
      daemonIOSchedClass = lib.mkDefault "best-effort";
      daemonCPUSchedPolicy = lib.mkDefault "other";
      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };
      settings = {
        trusted-users = [
          "root"
          "@wheel"
        ];
        experimental-features = [
          "flakes"
          "nix-command"
          "auto-allocate-uids"
          "cgroups"
        ];
        substituters = lib.mkForce [
          "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
          "https://mirrors.ustc.edu.cn/nix-channels/store"
          "https://mirror.sjtu.edu.cn/nix-channels/store"
          "https://nix-community.cachix.org"
          "https://cache.nixos.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        auto-optimise-store = true;
        auto-allocate-uids = true;
        build-poll-interval = 1;
        build-users-group = "nixbld";
        fallback = true;
        max-jobs = "auto";
        preallocate-contents = true;
        require-drop-supplementary-groups = true;
        sandbox-fallback = false;
        sync-before-registering = true;
        use-cgroups = true;
        use-xdg-base-directories = true;
      };
    };
  };
}
