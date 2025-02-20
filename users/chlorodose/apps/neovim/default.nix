{
  lib,
  inputs,
  outputs,
  ...
}:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];
  programs.nixvim = lib.mkMerge (
    [
      {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        withNodeJs = true;
        withRuby = false;
        impureRtp = false;
        wrapRc = true;
        nixpkgs.useGlobalPackages = true;
      }
    ]
    ++ (lib.map import (outputs.lib.scanPath ./.))
  );
}
