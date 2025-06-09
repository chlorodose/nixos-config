lib: {
  getSecret = lib.path.append ../secrets;
  scanPath =
    path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: type:
          (type == "directory") || ((path != "default.nix") && (lib.strings.hasSuffix ".nix" path))
        ) (builtins.readDir path)
      )
    );
  listRoots = outputs:
    (lib.mapAttrsToList (name: value: value.config.system.build.toplevel) outputs.nixosConfigurations) ++
    (lib.mapAttrsToList (name: value: value.activationPackage) outputs.homeConfigurations);
}
