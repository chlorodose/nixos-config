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
  sops.secrets."oc-homelab/cert.pem" = {
    format = "binary";
    sopsFile = outputs.lib.getSecret "oc-homelab/cert.pem";
    mode = "400";
    owner = "root";
  };
  sops.secrets."oc-homelab/key.pem" = {
    format = "binary";
    sopsFile = outputs.lib.getSecret "oc-homelab/key.pem";
    mode = "400";
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
    certificate = config.sops.secrets."oc-homelab/cert.pem".path;
    privateKey = config.sops.secrets."oc-homelab/key.pem".path;
  };
  systemd.services."openconnect-vps-vpnhost" = {
    serviceConfig = {
      Type = lib.mkForce "notify";
      NotifyAccess = "all";
    };
    after = [
      "pppd-wan.service"
    ];
    postStart = "${pkgs.systemd}/bin/networkctl reconfigure vps-vpnhost";
  };
}
