{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.hyprland.enable {
    systemd.user.services.waybar.Unit.RequiredBy = [ "tray.target" ];
    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "graphical-session.target";
      };
      settings.main = {
        position = "top";
        margin-bottom = 0;
        modules-left = [
          "hyprland/workspaces"
        ];
        modules-center = [
          "hyprland/window"
        ];
        modules-right = [
          "pulseaudio"
          "backlight"
          "battery"
          "clock"
          "tray"
          "custom/lock"
          "custom/power"
        ];
      };
      settings.main."hyprland/workspaces" = {
        "on-click" = "activate";
        "format" = "{icon}";
        "all-outputs" = true;
        "format-icons" = {
          "1" = "";
          "2" = "󰖟";
          "3" = "";
          "4" = "󰎉";
          "5" = "󰛳";
          "default" = "";
        };
      };
      settings.main."tray" = {
        "icon-size" = 21;
        "spacing" = 10;
      };
      settings.main."custom/lock" = {
        "tooltip" = false;
        "on-click" = "${pkgs.systemd}/bin/loginctl lock-session";
        "format" = "";
      };
      settings.main."custom/power" = {
        "tooltip" = false;
        "on-click" = "${pkgs.uwsm}/bin/uwsm app -t service -- ${pkgs.wlogout}/bin/wlogout";
        "format" = "⏻";
      };
      style = ''
        * {
          font-size: 17px;
          min-height: 0;
        }

        #waybar {
          background: transparent;
          color: @text;
          margin: 5px 5px;
        }

        #workspaces {
          border-radius: 1rem;
          margin: 5px;
          background-color: @surface0;
          margin-left: 1rem;
        }

        #workspaces button {
          color: @lavender;
          border-radius: 1rem;
          padding: 0.4rem;
        }

        #workspaces button.active {
          color: @sky;
          border-radius: 1rem;
        }

        #workspaces button:hover {
          color: @sapphire;
          border-radius: 1rem;
        }

        #window,
        #tray,
        #backlight,
        #clock,
        #battery,
        #pulseaudio,
        #custom-lock,
        #custom-power {
          background-color: @surface0;
          padding: 0.5rem 1rem;
          margin: 5px 0;
        }

        #clock {
          color: @blue;
          border-radius: 0px 1rem 1rem 0px;
          margin-right: 1rem;
        }

        #battery {
          color: @green;
        }

        #battery.charging {
          color: @green;
        }

        #battery.warning:not(.charging) {
          color: @red;
        }

        #backlight {
          color: @yellow;
        }

        #backlight,
        #battery {
          border-radius: 0;
        }

        #pulseaudio {
          color: @maroon;
          border-radius: 1rem 0px 0px 1rem;
          margin-left: 1rem;
        }

        #custom-music {
          color: @mauve;
          border-radius: 1rem;
        }

        #custom-lock {
          border-radius: 1rem 0px 0px 1rem;
          color: @lavender;
        }

        #custom-power {
          margin-right: 1rem;
          border-radius: 0px 1rem 1rem 0px;
          color: @red;
        }

        #tray {
          margin-right: 1rem;
          border-radius: 1rem;
        }

        #workspaces button.urgent {
          color: @red;
        }

        #window {
          border-radius: 0.5rem;
        }
      '';
    };
  };
}
