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

        label = [
          {
            text = ''cmd[update:10000] date +"%B %d日, %A"'';
            color = "$text";
            font_size = 55;
            position = "100, 70";
            halign = "left";
            valign = "bottom";
            shadow_passes = 5;
            shadow_size = 10;
          }
          {
            text = ''cmd[update:10000] date +%R'';
            color = "$text";
            font_size = 55;
            position = "-100, 70";
            halign = "right";
            valign = "bottom";
            shadow_passes = 5;
            shadow_size = 10;
          }
          {
            text = "$USER";
            color = "$subtext1";
            font_size = 20;
            position = "-100, 160";
            halign = "right";
            valign = "bottom";
            shadow_passes = 5;
            shadow_size = 10;
          }
        ];

        input-field = [
          {
            dots_center = true;
            fade_on_empty = false;
            font_color = "$text";
            inner_color = "$surface2";
            outer_color = "$surface0";
            check_color = "$sky";
            fail_color = "$red";
            placeholder_text = "请输入密码";
            fail_text = "<b>密码错误($ATTEMPTS)</b>";
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
