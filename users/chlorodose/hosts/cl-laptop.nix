{ ... }:
{
  imports = [ ../. ];

  modules.desktop.enable = true;
  modules.gpg-agent.enable = true;
  modules.hyprland.enable = true;
  modules.bluetooth.enable = true;
}
