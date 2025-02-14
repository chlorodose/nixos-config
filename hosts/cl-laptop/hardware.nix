{ ... }:
{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  fileSystems."/".options = [ "size=2g" ];
  fileSystems."/boot" = {
    label = "BOOT";
    fsType = "vfat";
    options = [
      "rw"
      "sync"
      "nosuid"
      "nodev"
      "noexec"
      "uid=0"
      "gid=0"
      "umask=077"
      "utf8"
      "errors=remount-ro"
    ];
    neededForBoot = false;
  };
  swapDevices = [
    {
      label = "swap";
    }
  ];
  fileSystems."/nix" = {
    label = "nix";
    fsType = "ext4";
    options = [ "defaults" ];
    neededForBoot = true;
  };
  fileSystems."/mnt" = {
    label = "data";
    fsType = "bcachefs";
    neededForBoot = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
