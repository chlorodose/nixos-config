prev: lib: {
  getUser = lib.path.append ../users;
  getHost = lib.path.append ../hosts;
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
}
