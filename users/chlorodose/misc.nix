{
  config,
  ...
}:
{
  user.gpg.myKeys = [ ./chlorodose_public.asc ];
  programs.ssh.authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKF7rjnMuwq0bB/G4dXVSZHegO06qKm4BSBREUHml7Dp chlorodose <chlorodose@chlorodose.me>"
  ];
  programs.git = {
    userEmail = "chlorodose@chlorodose.me";
    userName = "chlorodose";
    signing = {
      format = "openpgp";
      key = "942DF679F2B394D4";
    };
  };
  modules.gpg-agent.enable = config.modules.desktop.enable;
  programs.nix-index.enable = true;
}
