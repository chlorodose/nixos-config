{ ... }:
{
  imports = [ ../. ];

  modules.desktop.enable = false;
  modules.gpg-agent.enable = false;
  modules.hyprland.enable = false;
}
