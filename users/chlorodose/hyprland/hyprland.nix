{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false; # for UWSM
      xwayland.enable = true;
      settings =
        let
          mod = "SUPER";
          altmod = "SUPER SHIFT";
          app = "uwsm app -t service --";
        in
        {
          monitor = ",preferred,auto,1.33333";
          bind = [
            "${mod}, Q, exec, ${app} kitty.desktop"
            "${mod}, E, exec, ${app} yazi.desktop"
            "${mod}, R, exec, ${app} ${config.programs.rofi.package}/bin/rofi -show drun -run-command \"${app} {cmd}\""

            "${mod}, C, killactive,"
            "${altmod}, C, forcekillactive,"
            "${mod}, V, togglefloating,"
            "${mod}, P, pseudo,"
            "${mod}, J, togglesplit,"
            "${mod}, M, exit,"

            "${mod}, left, movefocus, l"
            "${mod}, right, movefocus, r"
            "${mod}, up, movefocus, u"
            "${mod}, down, movefocus, d"

            "${mod}, 1, workspace, 1"
            "${mod}, 2, workspace, 2"
            "${mod}, 3, workspace, 3"
            "${mod}, 4, workspace, 4"
            "${mod}, 5, workspace, 5"
            "${mod}, 6, workspace, 6"
            "${mod}, 7, workspace, 7"
            "${mod}, 8, workspace, 8"
            "${mod}, 9, workspace, 9"
            "${mod}, 0, workspace, 10"

            "${altmod}, 1, movetoworkspace, 1"
            "${altmod}, 2, movetoworkspace, 2"
            "${altmod}, 3, movetoworkspace, 3"
            "${altmod}, 4, movetoworkspace, 4"
            "${altmod}, 5, movetoworkspace, 5"
            "${altmod}, 6, movetoworkspace, 6"
            "${altmod}, 7, movetoworkspace, 7"
            "${altmod}, 8, movetoworkspace, 8"
            "${altmod}, 9, movetoworkspace, 9"
            "${altmod}, 0, movetoworkspace, 10"
          ];
          bindm = [
            "${mod}, mouse:272, movewindow"
            "${mod}, mouse:273, resizewindow"
          ];
          bindel = [
            ",XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
            ",XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ",XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ",XF86AudioMicMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            ",XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%+"
            ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"
          ];
          source = [ "${./hyprland.conf}" ];
        };
    };
  };
}
