{ config, outputs, ... }:
{
  sops.secrets."ddns/cloudflare" = {
    sopsFile = outputs.lib.getSecret "services.yaml";
    mode = "400";
    owner = "root";
  };
  services.ddclient = {
    enable = true;
    verbose = true;
    interval = "10min";
    ssl = true;
    usev4 = "ifv4, if=wan";
    usev6 = "ifv6, if=wan";
    protocol = "cloudflare";
    zone = "chlorodose.me";
    username = "token";
    passwordFile = config.sops.secrets."ddns/cloudflare".path;
    domains = [ "home-ppp.chlorodose.me" ];
  };
}
