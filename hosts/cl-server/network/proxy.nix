{
  pkgs,
  ...
}:
{
  system.preserve.directories = [ "/var/lib/sing-box" ];
  systemd.network.networks."10-proxy" = {
    matchConfig = {
      Name = "lo";
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
        Type = "local";
        Table = 7890;
      }
    ];
    routingPolicyRules = [
      {
        FirewallMark = 7890;
        Table = 7890;
      }
    ];
  };
  networking.nftables.tables = {
    proxy = {
      name = "proxy";
      family = "inet";
      content = ''
        define EXCLUDES_PROXY_V4 = { 127.0.0.0/8, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, 255.255.255.255/32 };
        chain divert {
          type filter hook prerouting priority mangle; policy accept;
          ip daddr $EXCLUDES_PROXY_V4 accept
          iifname { lan, wg } ip protocol {tcp, udp} tproxy ip to 127.0.0.1:1234 meta mark set 7890 counter accept
          iifname { lan, wg } ip6 nexthdr {tcp, udp} tproxy ip6 to [::1]:1234 meta mark set 7890 counter accept
        }
      '';
    };
  };
  services.sing-box = {
    enable = true;
    settings = {
      log = {
        level = "info";
        timestamp = false;
      };
      route = {
        rules = [
          {
            ip_is_private = true;
            outbound = "direct";
          }
          {
            action = "sniff";
          }
          {
            protocol = "dns";
            action = "hijack-dns";
          }
          {
            rule_set = "site-proxy";
            outbound = "proxy";
          }
          {
            rule_set = [
              "site-direct"
              "steam-cn"
            ];
            outbound = "direct";
          }
          {
            action = "resolve";
            strategy = "prefer_ipv4";
          }
          {
            ip_is_private = true;
            outbound = "direct";
          }
          {
            rule_set = "geoip-cn";
            outbound = "direct";
          }
        ];
        rule_set = [
          {
            type = "remote";
            tag = "geoip-cn";
            format = "binary";
            url = "https://raw.githubusercontent.com/Loyalsoldier/geoip/release/srs/cn.srs";
            download_detour = "proxy";
          }
          {
            tag = "site-direct";
            type = "remote";
            format = "binary";
            url = "https://raw.githubusercontent.com/DDCHlsq/sing-ruleset/ruleset/direct.srs";
            download_detour = "proxy";
          }
          {
            tag = "site-proxy";
            type = "remote";
            format = "binary";
            url = "https://raw.githubusercontent.com/DDCHlsq/sing-ruleset/ruleset/proxy.srs";
            download_detour = "proxy";
          }
          {
            tag = "steam-cn";
            type = "remote";
            format = "binary";
            url = "https://raw.githubusercontent.com/DDCHlsq/sing-ruleset/ruleset/steamcn.srs";
            download_detour = "proxy";
          }
        ];
        final = "proxy";
      };
      inbounds = [
        {
          type = "tproxy";
          tag = "tproxy-in-v4";
          listen = "127.0.0.1";
          listen_port = 1234;
        }
        {
          type = "tproxy";
          tag = "tproxy-in-v6";
          listen = "::1";
          listen_port = 1234;
        }
        {
          type = "mixed";
          tag = "proxy-in";
          listen = "0.0.0.0";
          listen_port = 7890;
        }
      ];
      outbounds = [
        {
          type = "direct";
          tag = "direct";
        }
        {
          type = "direct";
          tag = "proxy";
          routing_mark = 1234;
        }
      ];
      experimental = {
        cache_file = {
          enabled = true;
        };
        clash_api = {
          external_controller = "0.0.0.0:9090";
          external_ui = "${pkgs.metacubexd}";
        };
      };
      dns = {
        servers = [
          {
            tag = "proxy-dns";
            address = "https://1.1.1.1/dns-query";
            address_resolver = "resolver-dns";
            detour = "proxy";
          }
          {
            tag = "direct-dns";
            address = "https://dns.alidns.com/dns-query";
            address_resolver = "resolver-dns";
            detour = "direct";
          }
          {
            tag = "resolver-dns";
            address = "223.5.5.5";
            detour = "direct";
          }
        ];
        rules = [
          {
            rule_set = [
              "site-proxy"
            ];
            server = "proxy-dns";
          }
          {
            rule_set = [
              "site-direct"
              "steam-cn"
            ];
            server = "direct-dns";
          }
        ];
        final = "direct-dns";
      };
    };
  };
}
