{
  pkgs,
  config,
  outputs,
  ...
}:
{
  systemd.network.networks."10-base-wan" = {
    matchConfig = {
      Name = "enp6s0";
    };
    linkConfig = {
      Unmanaged = true;
    };
  };
  systemd.network.networks."10-wan" = {
    matchConfig = {
      Type = "ppp";
      Name = "wan";
    };
    linkConfig = {
      RequiredForOnline = true;
    };
    networkConfig = {
      DHCP = "ipv6";
      LLMNR = false;
      IPv6AcceptRA = true;
      KeepConfiguration = true;
      DefaultRouteOnDevice = true;
      IPv4Forwarding = true;
      IPv6Forwarding = true;
      DHCPPrefixDelegation = true;
    };
    dhcpPrefixDelegationConfig = {
      UplinkInterface = ":self";
      SubnetId = 0;
      Announce = false;
      RouteMetric = 4294967295;
    };
    dhcpV6Config = {
      UseAddress = true;
      UseDelegatedPrefix = true;
    };
  };
  services.pppd.enable = true;
  services.pppd.peers."wan" = {
    name = "wan";
    enable = true;
    config = ''
      plugin pppoe.so

      linkname wan
      ifname wan

      enp6s0

      persist
      lcp-echo-interval 15
      lcp-echo-failure 3

      deflate 15
      predictor1
      bsdcomp 15

      noauth
      file ${config.sops.secrets."ppp/wan".path}

      noproxyarp
      nodefaultroute

      up_sdnotify
    '';
  };
  systemd.services."pppd-wan" = {
    bindsTo = [ "sys-subsystem-net-devices-enp6s0.device" ];
    after = [ "sys-subsystem-net-devices-enp6s0.device" ];
    serviceConfig = {
      Type = "notify";
      Slice = config.systemd.slices.system-network.name;
    };
    preStart = "${pkgs.iproute2}/bin/ip link set enp6s0 up";
    postStart = "${pkgs.systemd}/bin/networkctl reconfigure wan";
  };
  sops.secrets."ppp/wan" = {
    sopsFile = outputs.lib.getSecret "services.yaml";
    mode = "0400";
    owner = "root";
  };
}
