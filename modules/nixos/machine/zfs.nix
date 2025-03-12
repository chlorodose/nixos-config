{
  lib,
  config,
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      linuxKernel_latest_zfs =
        let
          zfsCompatibleKernelPackages = lib.filterAttrs (
            name: kernelPackages:
            (builtins.match "linux_[0-9]+_[0-9]+" name) != null
            && (builtins.tryEval kernelPackages).success
            && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
          ) final.linuxKernel.packages;
        in
        lib.last (
          lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
            builtins.attrValues zfsCompatibleKernelPackages
          )
        );
    })
  ];
}
