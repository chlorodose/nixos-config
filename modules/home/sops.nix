{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  sops = {
    gnupg.home = "${config.home.homeDirectory}/.gnupg";
    defaultSopsFile = lib.getSecret "default.yaml";
  };
  systemd.user.services."sops-nix".Unit.Requires = [ "gpg-agent.socket" ];
}
