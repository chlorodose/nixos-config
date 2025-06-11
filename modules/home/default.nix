{
  config,
  lib,
  outputs,
  pkgs,
  ...
}:
{
  imports = [ ../nix.nix ] ++ outputs.lib.scanPath ./.;
  options.modules.desktop.enable = lib.mkEnableOption "desktop";
  config = {
    home.language.base = "zh_CN.UTF-8";

    xdg = {
      enable = true;
      userDirs.enable = true;
      autostart.enable = true;
    };

    programs.git = {
      enable = true;
      lfs.enable = true;
      signing.signByDefault = true;
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
      };
    };

    programs.nix-your-shell.enable = true;

    home.packages =
      (with pkgs; [
        comma
        btop
        iotop
        iftop
        strace
        ltrace
        lsof
        lm_sensors
        pciutils
        usbutils
        nmap
        socat
        nix-tree
        ripgrep
        fd
        wireguard-tools
        smartmontools
        trashy
      ])
      ++ (
        lib.optionals config.modules.desktop.enable (with pkgs; [
          nixd
          nixfmt-rfc-style
          brightnessctl
          playerctl
        ])
      );
  };
}
