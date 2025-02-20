{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.hyprland.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
          no_fade_in = false;
        };

        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
          }
        ];

        input-field = [
          {
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 5;
            shadow_passes = 2;
          }
        ];
      };
    };
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "${pkgs.procps}/bin/pidof hyprlock || ${pkgs.uwsm}/bin/uwsm app -t service -- ${pkgs.hyprlock}/bin/hyprlock";
          unlock_cmd = "${pkgs.procps}/bin/pkill -USR1 hyprlock";
        };
      };
    };
  };
}
