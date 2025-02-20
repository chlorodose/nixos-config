{ config, lib, ... }:
{
  options.programs.ssh = {
    authorizedKeys = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
    };
  };
  options.user.gpg = {
    myKeys = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.path;
    };
  };
  config = {
    home.file.".ssh/authorized_keys".text = lib.concatLines config.programs.ssh.authorizedKeys;
    programs.gpg = {
      enable = true;
      publicKeys = lib.map (x: {
        source = x;
        trust = 5;
      }) config.user.gpg.myKeys;
    };
  };
}
