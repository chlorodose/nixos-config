{
  pkgs,
  lib,
  ...
}:
{
  nixpkgs.config = { };
  nixpkgs.overlays = [
  ];
  nix = {
    package = pkgs.lix;
    registry.system = {
      from = {
        id = "system";
        type = "indirect";
      };
      to = {
        type = "path";
        path = (builtins.toString ../.);
      };
    };
    settings = {
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
      trusted-public-keys = lib.mkForce [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
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
    };
  };
}
