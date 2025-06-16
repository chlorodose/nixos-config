{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      mkNixPak = inputs.nixpak.lib.nixpak {
        inherit lib pkgs;
      };
    })
  ];
}