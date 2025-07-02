{
  pkgs,
  lib,
  config,
  outputs,
  ...
}:
{
  systemd.slices.system-bitcoin.sliceConfig = {
    CPUWeight = 10;
    MemoryHigh = "32G";
    IOWeight = 10;
    IOWriteBandwidthMax = "/dev/disk/by-label/data 100M";
  };
  services.bitcoind.default = {
    enable = true;
    rpc.users = {
      observer = {
        name = "observer";
        passwordHMAC = "9f6d254138caa5b1eb11b70f5b9fe058$4bcb206292ac281a3c5d5d8327bce0ccae8765ad81af64112a5ed67070d42317";
      };
      admin = {
        name = "admin";
        passwordHMAC = "0933f36a3f28cbf866464ee5e6d614ca$5f670f4918dcd6f03ba19de43bfe379f6778ea59906455cac539f91df159ba03";
      };
    };
    package = pkgs.bitcoind-knots;
    dataDir = "/var/lib/bitcoind";
    pidFile = "/run/bitcoind/bitcoind.pid";
    user = "bitcoind";
    group = "bitcoind";
    extraConfig =
      let
        wall = "${lib.getBin pkgs.util-linux}/bin/wall";
      in
      ''
        statsenable=1

        assumevalid=0

        logtimestamps=0
        nodebuglogfile=1
        printtoconsole=1
        loglevelalways=1

        alertnotify=${wall} "Bitcoind Alert: %s"

        blockfilterindex=1
        coinstatsindex=1
        txindex=1
        peerblockfilters=12
        peerbloomfilters=1

        lowmem=8192

        par=72


        listen=0
        listenonion=0
        # v2onlyclearnet=1


        maxuploadtarget=1G


        server=1
        rest=1
        rpcbind=0.0.0.0
        rpcport=8332
        rpcallowip=0.0.0.0/0
        rpcallowip=::/0

        rpcdoccheck=1
      '';
  };
  system.preserve.directories = [ config.services.bitcoind.default.dataDir ];
  systemd.services."bitcoind-default".serviceConfig = {
    RuntimeDirectory = "bitcoind";
    StateDirectory = "bitcoind";
    Slice = config.systemd.slices.system-bitcoin.name;
  };
  systemd.services."bitcoind-default".wantedBy = lib.mkForce [ ];
}
