{
  lib,
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
        file = "/etc/ssh/ssh_host_ed25519_key";
        how = "bindmount";
        inInitrd = true;
        mode = "400";
      }
      {
        file = "/etc/ssh/ssh_host_rsa_key";
        how = "bindmount";
        inInitrd = true;
        mode = "400";
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
}
