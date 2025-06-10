{
  config,
  outputs,
  ...
}:
let
  wgSecret = {
    sopsFile = outputs.lib.getSecret "services.yaml";
    mode = "0440";
    owner = "root";
    group = "systemd-network";
  };
in
{
  imports = outputs.lib.scanPath ./.;

  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";

  sops.secrets."wireguard/private" = wgSecret;
  sops.secrets."wireguard/preshare/phone" = wgSecret;
  sops.secrets."wireguard/preshare/laptop" = wgSecret;

  services.avahi = {
    enable = true;
    openFirewall = false;
    allowInterfaces = config.networking.firewall.trustedInterfaces;
    publish = {
      enable = true;
      hinfo = true;
      domain = true;
      addresses = true;
      userServices = true;
      workstation = true;
    };
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
        {
          name = "m-phone";
          allowedIPs = [ "192.168.1.4/32" ];
          publicKey = "qnu6tNaO+AnYmYERhWuYy3wGcNDK7ItporEerZgYAk4=";
        }
        {
          name = "f-laptop";
          allowedIPs = [ "192.168.1.5/32" ];
          publicKey = "ao71yf/P66Mi0XRLpRcocRFaPekDIpy3ec8F9yNc/kk=";
        }
      ];
    };
  };
}
