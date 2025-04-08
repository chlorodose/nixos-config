{
  config,
  pkgs,
  lib,
  outputs,
  ...
}:
{
  imports = outputs.lib.scanPath ./.;
  options.modules.desktop.enable = lib.mkEnableOption "desktop";
  config = lib.mkIf config.modules.desktop.enable {
    systemd.sleep.extraConfig = "";
    networking.networkmanager.enable = true;
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_zen;
    fonts = {
      packages = with pkgs; [
        material-design-icons
        font-awesome
        noto-fonts-emoji
        maple-mono.NF-CN-unhinted
      ];
      fontconfig = {
        hinting.enable = false;
        defaultFonts = {
          monospace = [
            "Maple Mono NF CN"
            "Font Awesome 6 Free"
            "Material Design Icons"
          ];
          sansSerif = [
            "Maple Mono NF CN"
            "Font Awesome 6 Free"
            "Material Design Icons"
          ];
          serif = [
            "Maple Mono NF CN"
            "Font Awesome 6 Free"
            "Material Design Icons"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    security.rtkit.enable = true;
    security.polkit.enable = true;
    services.flatpak.enable = true;
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];
    system.preserve.directories = [ "/etc/NetworkManager" ];
  };
}
