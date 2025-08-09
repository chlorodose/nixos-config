{
  outputs,
  lib,
  ...
}:
{
  nixpkgs.overlays = [
    (
      final: prev:
      prev
      // (lib.listToAttrs (
        lib.map (
          sub:
          let
            pkg = final.callPackage sub { };
          in
          {
            name = pkg.pname;
            value = pkg;
          }
        ) (outputs.lib.scanPath ./.)
      ))
    )
  ];
}
