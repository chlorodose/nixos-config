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

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaSettings = true;
    nvidiaPersistenced = true;
    modesetting.enable = true;
    open = true;
  };
  fileSystems = let
        datapoolList = [ "datapool" "datapool/home" "datapool/home/250991817" "datapool/home/chlorodose" "datapool/nix" "datapool/srv" "datapool/srv/media" "datapool/var" "datapool/var/lib" "datapool/var/lib/postgresql" "datapool/var/lib/prometheus2" "datapool/var/log" ];
    in (builtins.listToAttrs (builtins.map (p: { name = (builtins.replaceStrings [ "datapool" ] [ "/mnt" ] p); value = {fsType = "zfs"; device = p; neededForBoot = true; }; }) datapoolList)) // {
      "/nix" = {
         device = "/mnt/nix";
         options = [ "bind" ];
         neededForBoot = true;
      };
      "/".options = [ "size=16g" ];
      "/boot" = {
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
     };
  boot.kernelParams = [ "nohibernate" ];

  networking.hostId = "0ecb4cbb";
  boot.initrd.supportedFilesystems.zfs = true;
  boot.supportedFilesystems.zfs = true;
  boot.zfs.removeLinuxDRM = true;

  nixpkgs.hostPlatform = "x86_64-linux";
}
