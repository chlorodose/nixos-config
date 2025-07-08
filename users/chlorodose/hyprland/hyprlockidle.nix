{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.hyprland.enable {
    programs.hyprlock = { # FIXME: Double hyprlock on wake
      enable = true;
      settings = {
        general = {
          immediate_render = true;
          hide_cursor = true;
        };

        background = {
          color = "rgba(0,0,0,1)";
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        };

        label = [
          {
            text = ''cmd[update:10000] ${pkgs.coreutils}/bin/date +"%B %d日, %A"'';
            color = "$text";
            font_size = 55;
            position = "100, 70";
            halign = "left";
            valign = "bottom";
            shadow_passes = 5;
            shadow_size = 10;
          }
          {
            text = ''cmd[update:10000] ${pkgs.coreutils}/bin/date +%R'';
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
          before_sleep_cmd = "${pkgs.elogind}/bin/loginctl lock-session";
          inhibit_sleep = 3;
        };
        listener = [
          {
            timeout = 150;
            on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10%";
            on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
          }
          {
            timeout = 150;
            on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -sd platform::kbd_backlight set 0";
            on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -rd platform::kbd_backlight";
          }
          {
            timeout = 300;
            on-timeout = "${pkgs.elogind}/bin/loginctl lock-sessionp";
          }
          {
            timeout = 900;
            on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
          }
        ];
      };
    };
  };
}
