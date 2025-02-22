{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.desktop.enable {
    systemd.user.services."fcitx5-daemon".Unit.After = [ "graphical-session.target" ];
    i18n.inputMethod.enabled = "fcitx5";
    i18n.inputMethod.fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-chinese-addons
    ];
    i18n.inputMethod.fcitx5.waylandFrontend = true;
    xdg.configFile = {
      "fcitx5/profile".text = ''
        [Groups/0]
        Name=Default
        Default Layout=us
        DefaultIM=keyboard-us

        [Groups/0/Items/0]
        Name=keyboard-us
        Layout=

        [Groups/0/Items/1]
        Name=pinyin
        Layout=

        [GroupOrder]
        0=Default
      '';
      "fcitx5/profile".force = true;
      "fcitx5/config".text = ''
        [Hotkey]
        EnumerateWithTriggerKeys=True

        [Hotkey/TriggerKeys]
        0=Shift+Shift_L
        1=Shift+Shift_R

        [Hotkey/PrevPage]
        0=Up

        [Hotkey/NextPage]
        0=Down
      '';
      "fcitx5/conf/cloudpinyin.conf".text = ''
        MinimumPinyinLength=3
        Backend=GoogleCN
      '';
    };
  };
}
