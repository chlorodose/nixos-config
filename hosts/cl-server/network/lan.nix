{ ... }:
{
  networking.bridges.lan.interfaces = [
    "enp2s0f0"
    "enp2s0f1"
  ];
  systemd.network.networks."10-lan" = {
    matchConfig = {
      Name = "lan";
    };
    networkConfig = {
      Address = [ "192.168.0.1/24" ];
      LLDP = true;
      EmitLLDP = true;
      MulticastDNS = true;
      LLMNR = true;
      DHCPServer = true;
      IPv6SendRA = true;
      IPv6AcceptRA = false;
      DHCPPrefixDelegation = true;
      IPv4Forwarding = true;
      IPv6Forwarding = true;
    };
    dhcpServerConfig = {
      PoolOffset = 100;
      PoolSize = 128;
      EmitDNS = true;
      DNS = [ "192.168.0.1" ];
      EmitNTP = true;
      NTP = [ "192.168.0.1" ];
      EmitRouter = true;
      EmitTimezone = true;
    };
    dhcpPrefixDelegationConfig = {
      UplinkInterface = "wan";
      SubnetId = 0;
      Announce = true;
    };
    ipv6SendRAConfig = {
      Managed = true;
      OtherInformation = true;
      EmitDNS = true;
      DNS = [ ];
    };
    bridgeConfig = {
      ProxyARP = true;
    };
  };
}
