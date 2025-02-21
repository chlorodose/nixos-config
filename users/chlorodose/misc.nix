{
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-index-database.hmModules.nix-index
  ];
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = false;
  user.gpg.myKeys = [ ./chlorodose_public.asc ];
  programs.git = {
    userEmail = "chlorodose@chlorodose.me";
    userName = "chlorodose";
    signing = {
      format = "openpgp";
      key = "942DF679F2B394D4";
    };
  };
  modules.gpg-agent.enable = config.modules.desktop.enable;
}
