{ config, ... }:
{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "nvme"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  systemd.settings.Manager = {
    DefaultDeviceTimeoutSec = "3s";
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaSettings = true;
    nvidiaPersistenced = true;
    modesetting.enable = true;
    open = true;
  };

  boot.kernelParams = [ "nohibernate" ];

  fileSystems."/".options = [ "size=16g" ];
  fileSystems."/boot" = {
    label = "BOOT";
    fsType = "vfat";
    options = [
      "rw"
      "async"
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
  fileSystems."/nix" = {
    device = "/mnt/nix";
    options = [ "bind" ];
    neededForBoot = true;
  };
  fileSystems."/mnt" = {
    label = "data";
    fsType = "bcachefs";
    neededForBoot = true;
    options = [
      "x-systemd.mount-timeout=15m"
    ];
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
