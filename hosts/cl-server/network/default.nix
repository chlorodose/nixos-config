{
  config,
  outputs,
  ...
}:
{
  imports = outputs.lib.scanPath ./.;

  sops.secrets."wireguard/private" = {
    sopsFile = outputs.lib.getSecret "services.yaml";
    mode = "0440";
    owner = "root";
    group = "systemd-network";
  };
  sops.secrets."wireguard/preshare/phone" = {
    sopsFile = outputs.lib.getSecret "services.yaml";
    mode = "0440";
    owner = "root";
    group = "systemd-network";
  };
  sops.secrets."wireguard/preshare/laptop" = {
    sopsFile = outputs.lib.getSecret "services.yaml";
    mode = "0440";
    owner = "root";
    group = "systemd-network";
  };
  # Network
  networking = {
    nat = {
      enable = true;
      internalInterfaces = [
        "lan"
        "wg"
      ];
      externalInterface = "wan";
    };

    firewall = {
      checkReversePath = false;
      trustedInterfaces = [
        "lan"
        "wg"
      ];
      pingLimit = "8/second burst 32 packets";
      extraForwardRules = ''
        iifname { "wan" } tcp flags syn tcp option maxseg size set rt mtu
        oifname { "wan" } tcp flags syn tcp option maxseg size set rt mtu
      '';
      rejectPackets = true;
      filterForward = true;
      allowedUDPPorts = [ 51820 ];
      interfaces.wan.allowedUDPPorts = [
        68
        546
      ];
      logRefusedConnections = false;
    };

    wireguard.interfaces.wg = {
      ips = [ "192.168.1.1/24" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets."wireguard/private".path;
      peers = [
        {
          name = "phone";
          allowedIPs = [ "192.168.1.2/32" ];
          publicKey = "12+lveD6bhdlprqxP9lxLx0nHpOI575L0ORbBjpUIys=";
          presharedKeyFile = config.sops.secrets."wireguard/preshare/phone".path;
        }
        {
          name = "laptop";
          allowedIPs = [ "192.168.1.3/32" ];
          publicKey = "FdE67l/tQ17htGEwPm05ZNllUcob6z34NXyPxfKcgQs=";
          presharedKeyFile = config.sops.secrets."wireguard/preshare/laptop".path;
        }
      ];
    };
  };
}
