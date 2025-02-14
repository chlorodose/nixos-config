{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.preservation.nixosModules.default
    (lib.mkAliasOptionModule
      [ "system" "preserve" ]
      [
        "preservation"
        "preserveAt"
        "main"
      ]
    )
  ];
  preservation.enable = true;
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "defaults"
    ];
    neededForBoot = true;
  };
  system.preserve.persistentStoragePath = lib.mkDefault "/mnt";
  system.preserve = {
    commonMountOptions = [
      "x-gvfs-hide"
      "x-gdu.hide"
    ];
    files = [
      {
        file = "/etc/machine-id";
        how = "bindmount";
        inInitrd = true;
        mode = "444";
      }
      {
        file = "/var/lib/systemd/random-seed";
        how = "symlink";
        inInitrd = true;
        configureParent = true;
      }
    ];
    directories = [
      {
        directory = "/var/lib/nixos";
        inInitrd = true;
      }
      {
        directory = "/etc/ssh";
        inInitrd = true;
      }
      "/var/lib/systemd/timers"
      "/var/lib/systemd/coredump"
      "/var/log"
      "/srv"
    ];
    users.root = {
      home = "/root";
      directories = [
        {
          directory = ".ssh";
          mode = "0700";
        }
      ];
    };
  };
  systemd.services.systemd-machine-id-commit.serviceConfig.ExecStart = [
    ""
    "${pkgs.systemd}/bin/systemd-machine-id-setup"
  ];
}
