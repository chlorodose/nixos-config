{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false; # for UWSM
      xwayland.enable = true;
      settings = {
        "$mod" = "SUPER";
        "monitor" = ",preferred,auto,1.33333";
        "$appPrefix" = "uwsm app --";
        "$terminal" = "kitty";
        "$fileManager" = "dolphin";
        "$menu" = ''rofi -show drun -run-command "uwsm app -- {cmd}"'';
        source = [ "${./hyprland.conf}" ];
      };
    };
  };
}
