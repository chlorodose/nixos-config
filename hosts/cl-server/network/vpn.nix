{
  config,
  lib,
  outputs,
  pkgs,
  ...
}:
{
  systemd.network.networks."10-vps-vpnhost" = {
    matchConfig = {
      Name = "vps-vpnhost";
    };
    linkConfig = {
      RequiredForOnline = true;
    };
    networkConfig = {
      KeepConfiguration = true;
    };
    routes = [
      {
        Gateway = "0.0.0.0";
        Table = 1234;
      }
    ];
    routingPolicyRules = [
      {
        Family = "both";
        FirewallMark = 1234;
        Table = 1234;
      }
    ];
  };
  sops.secrets."vpn/cert.pem" = {
    format = "binary";
    sopsFile = outputs.lib.getSecret "vpn/cert.pem";
    mode = "0400";
    owner = "root";
  };
  sops.secrets."vpn/key.pem" = {
    format = "binary";
    sopsFile = outputs.lib.getSecret "vpn/key.pem";
    mode = "0400";
    owner = "root";
  };
  networking.openconnect.interfaces.vps-vpnhost = {
    gateway = "104.194.91.98:8443";
    user = "homelab";
    extraOptions = {
      servercert = "pin-sha256:3w4Hpfu9MrJsTeGvXeNrAWTGTGNiY/V5xGTwJk1jiLY=";
      script = ''${pkgs.writeScriptBin "configure-vps-vpnhost" ''
        ${pkgs.vpnc-scripts}/bin/vpnc-script && systemd-notify --ready
      ''}/bin/configure-vps-vpnhost'';
    };
    protocol = "anyconnect";
    certificate = config.sops.secrets."vpn/cert.pem".path;
    privateKey = config.sops.secrets."vpn/key.pem".path;
  };
  systemd.services."openconnect-vps-vpnhost" = {
    serviceConfig = {
      Type = lib.mkForce "notify";
      NotifyAccess = "all";
      Slice = config.systemd.slices.system-network.name;
    };
    after = [
      config.systemd.services."pppd-wan".name
    ];
    postStart = "${pkgs.systemd}/bin/networkctl reconfigure vps-vpnhost";
  };
  
}
